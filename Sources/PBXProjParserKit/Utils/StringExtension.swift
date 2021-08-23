//
//  StringExtension.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/23.
//

import Foundation

extension String {
    var intValue: Int? {
        return Int(self)
    }
}

//extension Optional where Wrapped == String {
//    var intValue: Int? {
//        if self == nil {
//            return nil
//        }
//        return Int(self!)
//    }
//}
