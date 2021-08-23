//
//  main.swift
//  PBXProjParser
//
//  Created by 柳钰柯 on 2021/8/16.
//

import Foundation
import CommandLineKit

let THEMIS_VERSION = "1.0"

// 命令行参数解析
let filePath = StringOption(shortFlag: "f", longFlag: "file", required: true, helpMessage: "The file or directory to be parsed")
let searchName = StringOption(shortFlag: "s", longFlag: "search", required: true, helpMessage: "The file to be searched, file name must contains extension.")
//let analyzeModule = StringOption(shortFlag: "a", longFlag: "analyze", required: true, helpMessage: "The module to be analyzed, supported: a pod of cocoapods.")

let cli = CommandLine()
cli.addOptions(filePath)
cli.addOption(searchName)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

// 必须指定文件路径
guard let paths = filePath.value else {
    print("Error: File path was missing!\n")
    cli.printUsage()
    exit(EX_USAGE)
}
guard let toSearch = searchName.value else {
    print("Error: search name was missing!\n")
    cli.printUsage()
    exit(EX_USAGE)
}

let parser = PBXProjParser()
print(paths)
parser.path = paths
let node = try parser.run()
print(node.rootObject)
guard let fileRef = node.objects.pbxFileReferenceSecion.first(where:{$0.path == toSearch}) else {
    print("Do not find fileRef of :\(toSearch)")
    exit(RETURN)
}
print("\(toSearch) has been found:", fileRef)
var path = toSearch
var key = fileRef.id
while let group = node.objects.pbxGroupSecion.first(where: {$0.children.contains(where: {$0 == key})}), group.path?.isEmpty == false {
    if group.path!.first != "." && group.path!.first != "/" {
        path = "/\(group.path!)\(path)"
    } else {
        path = "\(group.path!)\(path)"
    }
    key = group.id
}
print(path)
