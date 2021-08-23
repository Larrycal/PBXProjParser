//
//  PBXProjNode.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

struct PBXProjNode: Node {
    var archiveVersion: String
    
    var objectVersion: String
    
    var objects: [Section]
    
    var rootObject: PBXProjectSectionItem
}

extension Array where Element == Section {
    var pbxFileReferenceSecion:[PBXFileReferenceSectionItem] {
        let rs:[PBXFileReferenceSectionItem] = []
        return filter({$0.type == .fileReference}).reduce(into: rs) { rs, section in
            if let items = section.items as? [PBXFileReferenceSectionItem] {
                rs.append(contentsOf: items)
            } else {
                rs.append(contentsOf: [])
            }
        }
    }
    
    var pbxGroupSecion: [PBXGroupSectionItem] {
        let rs:[PBXGroupSectionItem] = []
        return filter({$0.type == .group}).reduce(into: rs) { rs, section in
            if let items = section.items as? [PBXGroupSectionItem] {
                rs.append(contentsOf: items)
            } else {
                rs.append(contentsOf: [])
            }
        }
    }
}
