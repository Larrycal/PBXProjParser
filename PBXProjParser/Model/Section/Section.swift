//
//  Section.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

enum SectionType {
    /// PBXGroupSectionItem
    case group
    /// PBXBuildFileSectionItem
    case buildFile
    /// PBXFileReferenceSectionItem
    case fileReference
    /// PBXProjectSectionItem
    case project
}

struct Section {
    var type: SectionType
    var items: [SectionItem]
}
