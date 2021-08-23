//
//  Preprocessor.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/17.
//

import Foundation

protocol FilePass {
    func run(onFile file: String) -> String
}

class Preprocessor {
    static let shared = Preprocessor()
    
    func processFile(_ path: String) -> String {
        filePassList.reduce(path) { path, pass in
            pass.run(onFile: path)
        }
    }
    
    func register(_ filePass: FilePass) {
        filePassList.append(filePass)
    }
    
    private var filePassList:[FilePass] = []
}
