//
//  StreamWriter.swift
//  Themis
//
//  Created by 柳钰柯 on 2021/8/12.
//

import Foundation

class StreamWriter {
    let encoding: String.Encoding
    var fileHandle: FileHandle!
    let delimiter: String

    init?(path: String, delimiter: String = "\n", encoding: String.Encoding = .utf8) {
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        guard let fileHandle = FileHandle(forWritingAtPath: path) else { return nil }
        self.encoding = encoding
        self.fileHandle = fileHandle
        self.delimiter = delimiter
    }

    deinit {
        self.close()
    }

    @discardableResult
    func write(_ content: String) -> Bool {
        precondition(fileHandle != nil, "Attempt to write to closed file")
        if let data = "\(content)\(delimiter)".data(using: encoding) {
            fileHandle.write(data)
            return true
        }
        return false
    }

    /// Start writing from the beginning of file.
    func rewind() {
        fileHandle.seek(toFileOffset: 0)
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}
