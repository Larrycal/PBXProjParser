//
//  PBXGroupSectionItem.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

public struct PBXGroupSectionItem: SectionItem {
    public let isa: PBXFileISAType = .group
    public var id: String
    public var children: [String]
    public var path: String?
    public var name: String?
    public var sourceTree: String
}
