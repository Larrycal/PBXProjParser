//
//  PBXProjectSectionItem.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

public struct PBXProjectSectionItem: SectionItem {
    public var isa: PBXFileISAType { .project }
    
    public var id: String
    
    
}
