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
let filePath = StringOption(shortFlag: "f", longFlag: "file", required: true, helpMessage: "The file or directory to be parsed, supported: .h and .m. Multiple arguments are separated by commas.")
//let analyzeModule = StringOption(shortFlag: "a", longFlag: "analyze", required: true, helpMessage: "The module to be analyzed, supported: a pod of cocoapods.")

let cli = CommandLine()
cli.addOptions(filePath)

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
//guard let module = analyzeModule.value else {
//    print("Error: Analyzed module was missing!\n")
//    cli.printUsage()
//    exit(EX_USAGE)
//}

let parser = PBXProjParser()
print(paths)
parser.path = paths
parser.run()
