//
//  SyntaxError.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/17.
//

import Foundation

enum SyntaxError: Error {
    case unexpected(String)
    case expected(String)
    case dismiss(String)
}
