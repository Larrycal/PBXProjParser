//
//  PBXFileReferenceSectionItem.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

public struct PBXFileReferenceSectionItem: SectionItem {
    public let isa: PBXFileISAType = .fileReference
    public var id: String
    public var fileEncoding: Int?
    public var lastKnownFileType: String?
    public var name: String?
    public var path: String
    public var sourceTree: String
    public var explicitFileType: String?
    public var includeInIndex: Int?
}
