//
//  PBXValue.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/23.
//

import Foundation

enum PBXValueRawType {
    case string
    case obj
    case array
}

protocol PBXValueType {
    var pbxRawType: PBXValueRawType { get }
}

extension String: PBXValueType {
    var pbxRawType: PBXValueRawType { return .string }
}

extension Dictionary: PBXValueType where Key == String, Value == PBXValueType {
    var pbxRawType: PBXValueRawType { return .obj }
}

extension Array: PBXValueType where Element == PBXValueType {
    var pbxRawType: PBXValueRawType { return . array}
}
