//
//  PBXProjParser.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/17.
//

import Foundation

class PBXProjParser {
    var path: String = ""
    
    func run() {
        reset()
        if let content = try? String(contentsOfFile: path) {
            tokens = PBXLexer(content).allTokens
            do {
                let obj = try parse()
                let objects = obj.members.first(where: { $0.name.name == "objects" && $0.value.subType == .obj }).flatMap({$0 as? PBXObjCharacter})
                
                objects?.members.forEach({ member in
                    if member.value.subType == .obj,let item = member.value as? PBXObjCharacter {
                        if item.members.contains(where: {$0.name.name == "isa" && ($0.value as? PBXNameCharacter)?.name == "PBXBuildFile"}),
                           let fileRef = (item.members.filter({$0.name.name == "fileRef"}).first?.value as? PBXNumCharacter)?.num {
                            
                            PBXBuildFileSectionItem(id: member.name.name, fileRef: fileRef, settings: <#T##[String : Any]?#>)
                        }
                    }
                })
                let node = PBXProjNode(archiveVersion: <#T##Int#>, classes: <#T##Any#>, objectVersion: <#T##Int#>, objects: <#T##[Section]#>, rootObject: <#T##Section#>)
            } catch {
                print(error)
            }
        }
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
    func parse() throws -> PBXObjCharacter {
        guard validToken?.type == .leftCurlyBracket else {
            throw SyntaxError.expected("Expected token: \"{\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightCurlyBracket {
            consume()
            return PBXObjCharacter(members: [])
        }
        let obj = PBXObjCharacter(members: try parseMembers())
        guard validToken?.type == .rightCurlyBracket else {
            throw SyntaxError.expected("Expected token: \"}\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        return obj
    }
    
    func parseObject() throws -> PBXObjCharacter {
        guard validToken?.type == .leftCurlyBracket else {
            throw SyntaxError.expected("Expected token: \"{\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightCurlyBracket {
            consume()
            return PBXObjCharacter(members: [])
        } else {
            let members = try parseMembers()
            guard validToken?.type == .rightCurlyBracket else {
                throw SyntaxError.expected("Expected token: \"}\" do not find. But got: \(validToken as Any). Please check sytax")
            }
            consume()
//            guard validToken?.type == .semicolon else {
//                throw SyntaxError.expected("Expected token: \";\" do not find. But got: \(validToken as Any). Please check sytax")
//            }
//            consume()
            return PBXObjCharacter(members: members)
        }
    }
    
    func parseMembers() throws -> [PBXMemberCharacter] {
        var members: [PBXMemberCharacter] = []
        let member = try parseMember()
        members.append(member)
        guard validToken?.type == .semicolon else {
            throw SyntaxError.expected("Expected token: \";\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightCurlyBracket {
            return members
        }
        members.append(contentsOf: try parseMembers())
        return members
    }
    
    func parseMember() throws -> PBXMemberCharacter {
        guard validToken?.type == .name || validToken?.type == .number || validToken?.type == .doubleQuote else {
            throw SyntaxError.expected("Expected token: \"NameToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        var name: PBXNameCharacter
        if validToken?.type == .doubleQuote {
            name = PBXNameCharacter(name: try parseString().string)
        } else {
            name = PBXNameCharacter(name: validToken!.text)
        }
        consume()
        guard validToken?.type == .equal else {
            throw SyntaxError.expected("Expected token: \"EqualToken\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        let value = try parseValue()
        return PBXMemberCharacter(name: name, value: value)
    }
    
    func parseValue() throws -> PBXValueCharacter {
        if let token = validToken {
            if token.type == .number  {
                return PBXNumCharacter(num: try parseNums())
            } else if token.type == .name {
                return PBXNameCharacter(name: try parseName())
            } else if token.type == .dot {
                return PBXNameCharacter(name: try parsePath())
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
    
    func parseArray() throws -> PBXArrayCharacter {
        guard validToken?.type == .leftParenthesis else {
            throw SyntaxError.expected("Expected token: \"(\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        if validToken?.type == .rightParenthesis {
            consume()
            return PBXArrayCharacter(array: [])
        }
        let elements = try parseElements()
        guard validToken?.type == .rightParenthesis else {
            throw SyntaxError.expected("Expected token: \")\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        return PBXArrayCharacter(array: elements)
    }
    
    func parseElements() throws -> [PBXValueCharacter] {
        var elements: [PBXValueCharacter] = []
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
    
    func parseString() throws -> PBXStringCharacter {
        guard validToken?.type == .doubleQuote else {
            throw SyntaxError.expected("Expected token: \" do not find. But got: \(validToken as Any). Please check sytax")
        }
        consume()
        var str = ""
        while let token = validToken, token.type != .doubleQuote {
            str += "\(token.text)"
            consume()
        }
        if validToken?.type == .doubleQuote {
            consume()
            return PBXStringCharacter(string: "\"\(str)\"")
        }
        throw SyntaxError.expected("Expected token: \" do not find to the end. Please check sytax")
    }
    
    func parseName() throws -> String {
        guard validToken?.type == .name else {
            throw SyntaxError.expected("Expected token: \"NameToken\" do not find. But got: \(validToken as Any). Please check sytax")
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
        guard validToken?.type == .dot else {
            throw SyntaxError.expected("Expected token: \".\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        var str = validToken!.text
        consume()
        if validToken?.type == .dot {
            str += validToken!.text
            consume()
            if validToken?.type == .slash {
                str += validToken!.text
                consume()
            } else {
                throw SyntaxError.expected("Expected token: \".\" or \" /\" do not find. But got: \(validToken as Any). Please check sytax")
            }
        } else if validToken?.type == .slash {
            if validToken?.type == .slash {
                str += validToken!.text
                consume()
            }
        } else {
            throw SyntaxError.expected("Expected token: \".\" or \" /\" do not find. But got: \(validToken as Any). Please check sytax")
        }
        
        return try str + parseName()
    }
    
    func peekFor(_ token: PBXToken) throws -> Int {
        let backup = index
        while let current = validToken {
            if token == current {
                return index
            }
        }
        index = backup
        throw SyntaxError.expected(token.text)
    }
}
