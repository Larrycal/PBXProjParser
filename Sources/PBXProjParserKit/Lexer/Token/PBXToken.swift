//
//  PBXToken.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/17.
//

import Foundation

enum PBXTokenType {
    /// 未知类型
    case unknown
    /// 文件结束
    case endOfFile
    /// 反斜线: /
    case slash
    /// 星号: *
    case asterisk
    /// 点: .
    case dot
    /// 分号: ;
    case semicolon
    /// 叹号: !
    case exclamation
    /// 美元符号: $
    case dollar
    /// 行注释: //
    case annotation
    /// 左注释符号: /*
    case leftAnnotation
    /// 右注释符号: */
    case rightAnnotation
    /// 回车： \n
    case `return`
    /// 名称 (包括变量、类名、方法等所有名称)
    case name
    /// 数字
    case number
    /// 左尖括号：<
    case leftAngleBracket
    /// 右尖括号: >
    case rightAngleBracket
    /// 左圆括号: (
    case leftParenthesis
    /// 右圆括号: )
    case rightParenthesis
    /// 左大括号: {
    case leftCurlyBracket
    /// 右大括号: }
    case rightCurlyBracket
    /// 左中括号: [
    case leftSquareBracket
    /// 右中括号: ]
    case rightSquareBracket
    /// 冒号: :
    case colon
    /// 逗号: ,
    case comma
    /// 等号: =
    case equal
    /// 下划线: _
    case underline
    /// 加号: +
    case plus
    /// 减号: -
    case minus
    /// 双引号: "
    case doubleQuote
    /// 空格:
    case space
    /// 反斜线: \
    case backslash
    /// 艾特: @
    case at
//    /// 源码类型: .m .swift
//    case sourceFile
//    /// 头文件: .h
//    case headerFile
//    /// framework类型: .framwork
//    case framework
//    /// 上级路径: ../
//    case parentDirectory
}

// MARK: - 词法单元
struct PBXToken {
    var type: PBXTokenType // 词法单元类型
    var text: String    // 词法单元的值
    
    init(type: PBXTokenType, text: String) {
        self.type = type
        self.text = text
    }
}

extension PBXToken: Equatable {
    static func ==(lhs: PBXToken, rhs: PBXToken) -> Bool {
        if lhs.type == .name && rhs.type == .name {
            return lhs.text == rhs.text
        } else {
            return lhs.type == rhs.type
        }
    }
}

extension PBXToken: CustomStringConvertible {
    var description: String {
        return "\(text)"
    }
}

extension Array where Element == PBXToken {
    /// 将Token数组中每一个Token的text连接起来
    func joinedText(separator: String) -> String {
        let texts = self.map { $0.text }
        return texts.joined(separator: separator)
    }
}
