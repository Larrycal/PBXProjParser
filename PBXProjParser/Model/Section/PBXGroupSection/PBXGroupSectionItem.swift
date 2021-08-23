//
//  PBXGroupSectionItem.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

struct PBXGroupSectionItem: SectionItem {
    let isa: PBXFileISAType = .group
    var id: String
    var children: [PBXFileReferenceSectionItem]
    var path: String?
    var name: String?
    var sourceTree: String
}
