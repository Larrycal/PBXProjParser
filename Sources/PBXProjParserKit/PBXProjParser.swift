//
//  PBXProjParser.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/17.
//

import Foundation

public class PBXProjParser {
    public var path: String = ""
    public init() { }
    public func run() throws -> PBXProjNode {
        reset()
        let content = try String(contentsOfFile: path)
        tokens = PBXLexer(content).allTokens
        
        let obj = try parse()
        let objects = obj["objects"] as? [String: PBXValueType]
        
        var buildFile:[String: PBXValueType] = [:]
        var buildFileSection = Section(type: .buildFile, items: [])
        
        var fileRefs:[String: PBXValueType] = [:]
        var fileRefsSection = Section(type: .fileReference, items: [])
        var fileRefItemsHash = [String: PBXFileReferenceSectionItem]()
        
        var groups:[String: PBXValueType] = [:]
        var groupSection = Section(type: .group, items: [])
        
        var projects:[String: PBXValueType] = [:]
        var projectsSection = Section(type: .project, items: [])
        
        objects?.forEach({
            if value(for: "isa", in: $0.value) == "PBXBuildFile" { // PBXBuildFile section
                buildFile[$0.key] = $0.value
                guard let fileRef:String = value(for: "isa", in: $0.value) else {
                    return
                }
                let settings:[String: PBXValueType]? = value(for: "settings", in: $0.value)
                let item = PBXBuildFileSectionItem(id: $0.key, fileRef: fileRef, settings: settings)
                buildFileSection.items.append(item)
            } else if value(for: "isa", in: $0.value) == "PBXFileReference" { // PBXFileReference section
                fileRefs[$0.key] = $0.value
                guard let path: String = value(for: "path", in: $0.value),
                      let sourceTree: String = value(for: "sourceTree", in: $0.value) else {
                    return
                }
                let includeIndex: String? = value(for: "includeInIndex", in: $0.value)
                let explicitFileType: String? = value(for: "explicitFileType", in: $0.value)
                let lastKnownFileType: String? = value(for: "lastKnownFileType", in: $0.value)
                let fileEncoding: String? = value(for: "fileEncoding", in: $0.value)
                let name: String? = value(for: "name", in: $0.value)
                let item = PBXFileReferenceSectionItem(id: $0.key, fileEncoding: fileEncoding?.intValue, lastKnownFileType: lastKnownFileType, name: name, path: path, sourceTree: sourceTree, explicitFileType: explicitFileType, includeInIndex: includeIndex?.intValue)
                fileRefsSection.items.append(item)
                fileRefItemsHash[$0.key] = item
            } else if value(for: "isa", in: $0.value) == "PBXGroup" { // PBXGroup section
                groups[$0.key] = $0.value
            } else if value(for: "isa", in: $0.value) == "PBXProject" { // PBXProject section
                projects[$0.key] = $0.value
                let item = PBXProjectSectionItem(id: $0.key)
                projectsSection.items.append(item)
            }
        })
        
        var groupSectionHash:[String:PBXGroupSectionItem] = [:]
        // 按key排序后处理group，可以确保children中的group已经配置完成
        try groups.sorted(by: {$0.key < $1.key}).forEach({ key, result in
            guard let children:[String] = (value(for: "children", in: result) as [PBXValueType]?) as? [String],
                  let sourceTree: String = value(for: "sourceTree", in: result) else {
                throw SyntaxError.dismiss("Dismiss value for key: sourceTree or children in object:\(key)")
            }
            let path:String? = value(for: "path", in: result)
            let name:String? = value(for: "name", in: result)
            let item = PBXGroupSectionItem(id: key, children: children, path: path, name: name, sourceTree: sourceTree)
            groupSectionHash[key] = item
            groupSection.items.append(item)
        })
        
        guard let version: String = value(for: "archiveVersion", in: obj),
              let objVersion: String = value(for: "objectVersion", in: obj),
              let rootObjHash:String = value(for: "rootObject", in: obj),
              let rootObj = projectsSection.items.first(where: { $0 is PBXProjectSectionItem && $0.id == rootObjHash}) as? PBXProjectSectionItem else {
            throw SyntaxError.dismiss("Dismiss value for key:\"rootObject\"")
        }
        return PBXProjNode(archiveVersion: version, objectVersion: objVersion, objects: [buildFileSection,fileRefsSection,groupSection,projectsSection], rootObject: rootObj)
    }
    
    private var currentToken: PBXToken? {
        if index >= tokens.endIndex {
            return nil
        }
        return tokens[index]
    }
    
    private var validToken: PBXToken? {
        var annotationMode = false
        while index < tokens.endIndex, tokens[index].type == .return || tokens[index].type == .space || tokens[index].type == .leftAnnotation || tokens[index].type == .annotation || annotationMode {
            if tokens[index].type == .leftAnnotation || tokens[index].type == .annotation {
                annotationMode = true
            }
            if annotationMode && (tokens[index].type == .rightAnnotation || tokens[index].type == .return) {
                annotationMode = false
            }
            index = tokens.index(after: index)
        }
        if index < tokens.endIndex {
            return tokens[index]
        }
        return nil
    }
    
    private var index: Int = 0
    
    private var tokens:[PBXToken] = []
    
    private var tokenEnd: Bool {
        return index >= tokens.endIndex
    }
    
    private var tokenStack:[PBXToken] = []
}

// MARK: - private
private extension PBXProjParser {
    func reset() {
        index = 0
        tokens = []
    }
    
    func consume() {
        index = tokens.index(after: index)
    }
}

// MARK: - parse
private extension PBXProjParser {
    func parse() throws -> [String : PBXValueType] {
        guard validToken?.type == .leftCurlyBracket else {
            throw SyntaxError.expected("Expected token: \"{\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightCurlyBracket {
            consume()
            return [:]
        }
        let obj = try parseMembers()
        guard validToken?.type == .rightCurlyBracket else {
            throw SyntaxError.expected("Expected token: \"}\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        return obj
    }
    
    func parseObject() throws -> [String : PBXValueType] {
        guard validToken?.type == .leftCurlyBracket else {
            throw SyntaxError.expected("Expected token: \"{\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightCurlyBracket {
            consume()
            return [:]
        } else {
            let members = try parseMembers()
            guard validToken?.type == .rightCurlyBracket else {
                throw SyntaxError.expected("Expected token: \"}\" do not find. But got: \(validToken as Any). Please check sytax")
            }
            consume()
            return members
        }
    }
    
    func parseMembers() throws -> [String : PBXValueType] {
        var members: [String : PBXValueType] = [:]
        let member = try parseMember()
        members[member.key] = member.value
        guard validToken?.type == .semicolon else {
            throw SyntaxError.expected("Parse members error: Expected token: \";\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightCurlyBracket {
            return members
        }
        members.merge(try parseMembers(), uniquingKeysWith: { current,new in new })
        return members
    }
    
    func parseMember() throws -> (key: String,value: PBXValueType) {
        guard validToken?.type == .name || validToken?.type == .number || validToken?.type == .doubleQuote else {
            throw SyntaxError.expected("Expected token: \"NameToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        
        var name: String
        if validToken?.type == .name { // name or domin
            if peekForValidToken(after: 1)?.type == .dot {
                name = try parseDomin()
            } else if peekForValidToken(after: 1)?.type == .slash {
                name = try parseSystemPath()
            } else {
                name = try parseName()
            }
        } else if validToken?.type == .number {
            name = validToken!.text
            consume()
        } else if validToken?.type == .dot { // currentPath or parentPath
            if peekForValidToken(after: 1)?.type == .dot {
                name = try parseParentPath()
            } else {
                name = try parseCurrentPath()
            }
        } else if validToken?.type == .slash { // rootPath
            name = try parseRootPath()
        } else if validToken?.type == .doubleQuote {
            name = try parseString()
        } else {
            throw SyntaxError.expected("Expected token: \"NameToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        
        guard validToken?.type == .equal else {
            throw SyntaxError.expected("Expected token: \"EqualToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        
        let value = try parseValue()
        return (name,value)
    }
    
    func parseValue() throws -> PBXValueType {
        if let token = validToken {
            if token.type == .number  {
                return try parseNums()
            } else if token.type == .name {
                if peekForValidToken(after: 1)?.type == .dot {
                    return try parseDomin()
                } else if peekForValidToken(after: 1)?.type == .slash {
                    return try parseSystemPath()
                } else {
                    return try parseName()
                }
            } else if token.type == .dot || token.type == .slash {
                return try parsePath()
            } else if token.type == .leftCurlyBracket {
                return try parseObject()
            } else if token.type == .leftParenthesis {
                return try parseArray()
            } else if token.type == .doubleQuote {
                return try parseString()
            } else {
                throw SyntaxError.expected("Expected token: \"ValueToken\" do not find. But got: \(validToken as Any). Please check sytax")
            }
        } else {
            throw SyntaxError.expected("Expected token: \"ValueToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
    }
    
    func parseArray() throws -> [PBXValueType] {
        guard validToken?.type == .leftParenthesis else {
            throw SyntaxError.expected("Expected token: \"(\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightParenthesis {
            consume()
            return []
        }
        let elements = try parseElements()
        guard validToken?.type == .rightParenthesis else {
            throw SyntaxError.expected("Expected token: \")\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        return elements
    }
    
    func parseElements() throws -> [PBXValueType] {
        var elements: [PBXValueType] = []
        let value = try parseValue()
        elements.append(value)
        guard validToken?.type == .comma else {
            throw SyntaxError.expected("Expected token: \",\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightParenthesis {
            return elements
        }
        elements.append(contentsOf: try parseElements())
        return elements
    }
    
    func parseString() throws -> String {
        guard validToken?.type == .doubleQuote else {
            throw SyntaxError.expected("Expected token: \" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        var str = ""
        while let token = currentToken, token.type != .doubleQuote {
            str += "\(token.text)"
            consume()
        }
        if currentToken?.type == .doubleQuote {
            consume()
            return "\(str)"
        }
        throw SyntaxError.expected("Expected token: \" do not find to the end. Please check sytax")
    }
    
    func parseName() throws -> String {
        guard validToken?.type == .name else {
            throw SyntaxError.expected("Parse name error: Expected token: \"NameToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        var str = validToken!.text
        consume()
        if validToken?.type == .dot || validToken?.type == .slash {
            str += validToken!.text
            consume()
            str += try parseName()
        }
        return str
    }
    
    func parseNums() throws -> String {
        guard validToken?.type == .number else {
            throw SyntaxError.expected("Expected token: \"NumberToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        var str = validToken!.text
        consume()
        if validToken?.type != .dot {
            return str
        }
        str += validToken!.text
        consume()
        guard validToken?.type == .number else {
            throw SyntaxError.expected("Expected token: \"NumberToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        return try str + parseNums()
    }
    
    func parsePath() throws -> String {
        if validToken?.type == .dot {
            if peekForValidToken(after: 1)?.type == .dot {
                return try parseParentPath()
            } else {
                return try parseCurrentPath()
            }
        } else if validToken?.type == .slash {
            return try parseRootPath()
        } else if validToken?.type == .name {
            return try parseSystemPath()
        } else {
            throw SyntaxError.expected("Parse path error: token: \".\" or \"slash\" or \"NameToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
    }
    
    func parseCurrentPath() throws -> String {
        guard validToken?.type == .dot, peekForValidToken(after: 1)?.type == .slash else {
            throw SyntaxError.expected("Parse current path error: Expected token: \" . \" and \" / \" do not find. But got: \(validToken as Any). Please check sytax")
        }
        let path = validToken!.text
        consume()
        return try path + parseRootPath()
        
    }
    
    func parseRootPath() throws -> String {
        guard validToken?.type == .slash else {
            throw SyntaxError.expected("Parse root path error: Expected token: \" / \" do not find. But got: \(validToken as Any). Please check sytax")
        }
        var path = validToken!.text
        consume()
        if validToken?.type == .name {
            path += validToken!.text
            consume()
        } else {
            return path
        }
        if validToken?.type == .slash {
            return try path + parseRootPath()
        } else {
            return path
        }
    }
    
    func parseParentPath() throws -> String {
        guard validToken?.type == .dot, peekForValidToken(after: 1)?.type == .dot else {
            throw SyntaxError.expected("Parse parent path error: Expected token: \" . \" and \" . \" do not find. But got: \(validToken as Any). Please check sytax")
        }
        var path = validToken!.text
        consume()
        path += validToken!.text
        consume()
        if validToken?.type == .slash {
            return try path + parseRootPath()
        } else {
            return path
        }
    }
    
    func parseSystemPath() throws -> String {
        guard validToken?.type == .name, peekForValidToken(after: 1)?.type == .slash else {
            throw SyntaxError.expected("Parse system path error: Expected token: \"name token\" and \" / \" do not find. But got: \(validToken as Any). Please check sytax")
        }
        var path = validToken!.text
        consume()
        path += validToken!.text
        consume()
        if validToken?.type == .name {
            return try path + parseSystemPath()
        } else {
            return path
        }
    }
    
    func parseDomin() throws -> String {
        guard peekForValidToken(after: 2)?.type == .name else {
            throw SyntaxError.expected("Parse domin Error: Expected token: \".\" or \" /\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        var domin = validToken!.text
        consume()
        domin += validToken!.text
        consume()
        domin += validToken!.text
        if validToken?.type == .dot {
            return try domin + parseDomin1()
        } else {
            return domin
        }
    }
    
    func parseDomin1() throws -> String {
        var domin = validToken!.text
        consume()
        if validToken?.type == .name {
            domin += validToken!.text
            consume()
        } else {
            throw SyntaxError.expected("Parse domin1 Error: Expected token: \".\" or \" /\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        if validToken?.type == .dot {
            return try domin + parseDomin1()
        } else {
            return domin
        }
    }
    
    // 查看从当前index开始数的第index个有效token,i ∈ [1,tokens.count)
    func peekForValidToken(after i: Int) -> PBXToken? {
        let backup = index
        var i = i
        var token: PBXToken?
        while i > 0 {
            token = validToken
            i -= 1
        }
        index = backup
        return token
    }
    
    @discardableResult
    func makeTokenValid() -> Bool {
        if currentToken == nil { return false }
        let invalidTokens:[PBXTokenType] = [.return,.space,.leftAnnotation,.annotation]
        if !invalidTokens.contains(currentToken!.type) { return true }
        var annotationMode = false
        while index < tokens.endIndex, tokens[index].type == .return || tokens[index].type == .space || tokens[index].type == .leftAnnotation || tokens[index].type == .annotation || annotationMode {
            if tokens[index].type == .leftAnnotation || tokens[index].type == .annotation {
                annotationMode = true
            }
            if annotationMode && (tokens[index].type == .rightAnnotation || tokens[index].type == .return) {
                annotationMode = false
            }
            index = tokens.index(after: index)
        }
        if index < tokens.endIndex {
            return true
        }
        return false
    }
}

// MARK: - read
private extension PBXProjParser {
    func value<T: PBXValueType>(for key: String, in objects: PBXValueType) -> T? {
        (objects as? [String: PBXValueType])?[key] as? T
    }
}
