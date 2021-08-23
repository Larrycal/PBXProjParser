//
//  PBXBuildFileSectionItem.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

struct PBXBuildFileSectionItem: SectionItem {
    var id: String
    let isa: PBXFileISAType = .build
    var fileRef: String
    var settings:[String:Any]?
}
