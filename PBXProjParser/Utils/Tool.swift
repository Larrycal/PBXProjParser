//
//  Tool.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/17.
//

import Foundation

func cancelAndExit(_ message:String?) {
    if let m = message {
        print(m)
    }
    exit(ECANCELED)
}
