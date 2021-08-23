//
//  PBXProjNode.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

struct PBXProjNode: Node {
    var archiveVersion: Int
    
    var classes: Any
    
    var objectVersion: Int
    
    var objects: [Section]
    
    var rootObject: Section
}
