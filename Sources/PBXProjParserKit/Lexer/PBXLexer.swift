//
//  PBXLexer.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/17.
//

import Foundation

class PBXLexer {
    
    init(_ input: String) {
        self.input = input
        self.index = input.startIndex
    }
    
    // MARK: - let
    let input: String
    
    // MARK: - private
    private var index: String.Index
    private var currentChar: Character {
        return input[index]
    }
    
    private var _token: [PBXToken]?
}

// MARK: - token
extension PBXLexer {
    var nextToken: PBXToken {
        while !fileEnd {
            switch currentChar {
            case "\t", "\r": // 空格
                skipSomeEscaping()
            case "\\":
                consume()
                return PBXToken(type: .backslash, text: "\\")
            case " ":
                consume()
                return PBXToken(type: .space, text: " ")
            case "\n":
                consume()
                return PBXToken(type: .return, text: "\n")
            case "/": // 左注释识别
                if tryLookahead("/*") {
                    return PBXToken(type: .leftAnnotation, text: "/*")
                }
                if tryLookahead("//") {
                    return PBXToken(type: .annotation, text: "//")
                }
                consume()
                return PBXToken(type: .slash, text: "/")
            case "*":
                if tryLookahead("*/") {
                    return PBXToken(type: .rightAnnotation, text: "*/")
                }
                consume()
                return PBXToken(type: .asterisk, text: "*")
            case "$":
                consume()
                return PBXToken(type: .dollar, text: "$")
            case "!":
                consume()
                return PBXToken(type: .exclamation, text: "!")
            case "(":
                consume()
                return PBXToken(type: .leftParenthesis, text: "(")
            case ")":
                consume()
                return PBXToken(type: .rightParenthesis, text: ")")
            case "{":
                consume()
                return PBXToken(type: .leftCurlyBracket, text: "{")
            case "}":
                consume()
                return PBXToken(type: .rightCurlyBracket, text: "}")
            case "<":
                consume()
                return PBXToken(type: .leftAngleBracket, text: "<")
            case ">":
                consume()
                return PBXToken(type: .rightAngleBracket, text: ">")
            case "[":
                consume()
                return PBXToken(type: .leftSquareBracket, text: "[")
            case "]":
                consume()
                return PBXToken(type: .rightSquareBracket, text: "]")
            case ",":
                consume()
                return PBXToken(type: .comma, text: ",")
            case ".":
                consume()
                return PBXToken(type: .dot, text: ".")
            case "=":
                consume()
                return PBXToken(type: .equal, text: "=")
            case ";":
                consume()
                return PBXToken(type: .semicolon, text: ";")
            case "\"":
                consume()
                return PBXToken(type: .doubleQuote, text: "\"")
            case "-":
                consume()
                return PBXToken(type: .minus, text: "-")
            case "_":
                consume()
                return PBXToken(type: .underline, text: "_")
            case "+":
                consume()
                return PBXToken(type: .plus, text: "+")
            case "@":
                consume()
                return PBXToken(type: .at, text: "@")
            default:
                if isLetter(currentChar) || currentChar == "_" {
                    let value = name()
                    return PBXToken(type: .name, text: value)
                } else if isNumber(currentChar) {
                    let value = number()
                    return PBXToken(type: .number, text: value)
                }
                print("无法识别的字符: \(currentChar)")
                exit(EX_DATAERR)
//                consume()
                continue
            }
        }
        
        return PBXToken(type: .endOfFile, text: "")
    }
    
    /// 获取所有的Token
    var allTokens: [PBXToken] {
        if _token != nil {
            return _token!
        }
        var result = [PBXToken]()
        var next = nextToken
        
        while next.type != .endOfFile {
            result.append(next)
            next = nextToken
        }
        _token = result
        return result
    }
}

// MARK: - match
private extension PBXLexer {
    func tryLookahead(_ text: String) -> Bool {
        let start = index
        do {
            try match(text)
            return true
        } catch {
            index = start
            return false
        }
    }
    
    func match(_ text: String) throws {
        var i = text.startIndex
        while i != text.endIndex && !fileEnd {
            if text[i] != currentChar {
                throw LexerError.notMatch
            }
            i = text.index(after: i)
            consume()
        }
    }
    
    /// 是否到达文件的结尾
    var fileEnd: Bool {
        return index == input.endIndex
    }
    
    /// 步进到下一个位置
    func consume() {
        index = input.index(after: index)
    }
    
    /// 跳过所有的空白符
    func skipSomeEscaping() {
        let ws = ["\t", "\r"]
        while !fileEnd && ws.contains(String(currentChar)) {
            consume()
        }
    }
    
    /// 字符是否为字母
    func isLetter(_ c: Character) -> Bool {
        return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z")
    }
    
    /// 字符是否为数字
    func isNumber(_ c: Character) -> Bool {
        return (c >= "0" && c <= "9")
    }
    
    func isHex(_ c: Character) -> Bool {
        return (c >= "a" && c <= "f") || (c >= "A" && c <= "F")
    }
    
    /// 解析一个变量名称
    func name() -> String {
        guard !fileEnd else {
            return ""
        }
        
        var name: [Character] = []
        var c: Character
        
        while !fileEnd {
            c = currentChar
            if isLetter(c) || isNumber(c) || c == "_" || c == "+" || c == "-" || c == "." {
                name.append(c)
                consume()
            } else {
                break
            }
        }
        
        return String(name)
    }
    
    
    /// 解析一串数字
    func number() -> String {
        guard !fileEnd else {
            return ""
        }
        
        var number: [Character] = []
        var c: Character
        
        while !fileEnd {
            c = currentChar
            if isNumber(c) || (isHex(c) && !number.isEmpty) {
                number.append(c)
                consume()
            } else {
                break
            }
        }
        
        return String(number)
    }
}

