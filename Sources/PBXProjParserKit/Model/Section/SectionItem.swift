//
//  SectionItem.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

public protocol SectionItem {
    var isa: PBXFileISAType { get }
    var id: String { get set }
}
