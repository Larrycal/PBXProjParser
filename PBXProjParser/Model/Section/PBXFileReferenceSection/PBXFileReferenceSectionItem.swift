//
//  PBXFileReferenceSectionItem.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

struct PBXFileReferenceSectionItem: SectionItem {
    let isa: PBXFileISAType = .fileReference
    var id: String
    var fileEncoding: Int?
    var lastKnownFileType: String
    var name: String?
    var path: String
    var sourceTree: String
    var explicitFileType: String
    var includeInIndex: Int?
}
