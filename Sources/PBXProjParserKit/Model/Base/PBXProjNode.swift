//
//  PBXProjNode.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation

public struct PBXProjNode: Node {
    public var archiveVersion: String
    
    public var objectVersion: String
    
    public var objects: [Section]
    
    public var rootObject: PBXProjectSectionItem
}

public extension Array where Element == Section {
    var pbxFileReferenceSection:[PBXFileReferenceSectionItem] {
        let rs:[PBXFileReferenceSectionItem] = []
        return filter({$0.type == .fileReference}).reduce(into: rs) { rs, section in
            if let items = section.items as? [PBXFileReferenceSectionItem] {
                rs.append(contentsOf: items)
            } else {
                rs.append(contentsOf: [])
            }
        }
    }
    
    var pbxGroupSection: [PBXGroupSectionItem] {
        let rs:[PBXGroupSectionItem] = []
        return filter({$0.type == .group}).reduce(into: rs) { rs, section in
            if let items = section.items as? [PBXGroupSectionItem] {
                rs.append(contentsOf: items)
            } else {
                rs.append(contentsOf: [])
            }
        }
    }
    
    var projectSection: [PBXProjectSectionItem] {
        let rs:[PBXProjectSectionItem] = []
        return filter({$0.type == .project}).reduce(into: rs) { rs, section in
            if let items = section.items as? [PBXProjectSectionItem] {
                rs.append(contentsOf: items)
            } else {
                rs.append(contentsOf: [])
            }
        }
    }
}
