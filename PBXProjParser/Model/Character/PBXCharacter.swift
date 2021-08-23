//
//  PBXCharacter.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/18.
//

import Foundation

enum PBXCharacterType {
    case member
    case value
}

enum PBXCharacterSubType {
    case num
    case name
    case array
    case obj
    case string
}

protocol PBXCharacter {
    var type: PBXCharacterType { get }
}

protocol PBXValueCharacter: PBXCharacter {
    var subType:PBXCharacterSubType { get }
}

struct PBXNumCharacter: PBXValueCharacter {
    var type: PBXCharacterType {
        return .value
    }
    
    var subType: PBXCharacterSubType {
        return .num
    }
    
    var num:String
}

struct PBXNameCharacter: PBXValueCharacter {
    var type: PBXCharacterType {
        return .value
    }
    
    var subType: PBXCharacterSubType {
        return .name
    }
    
    var name: String
}


struct PBXObjCharacter: PBXValueCharacter {
    var type: PBXCharacterType {
        return .value
    }
    
    var subType: PBXCharacterSubType {
        return .obj
    }
    
    var members: [PBXMemberCharacter]
}

struct PBXArrayCharacter: PBXValueCharacter {
    var type: PBXCharacterType {
        return .value
    }
    
    var subType: PBXCharacterSubType {
        return .array
    }
    
    var array: [PBXCharacter]
}

struct PBXStringCharacter: PBXValueCharacter {
    var type: PBXCharacterType {
        return .value
    }
    
    var subType: PBXCharacterSubType {
        return .string
    }
    
    var string: String
}

struct PBXMemberCharacter: PBXCharacter {
    var type: PBXCharacterType {
        return .member
    }
    
    var name: PBXNameCharacter
    var value: PBXValueCharacter
}
