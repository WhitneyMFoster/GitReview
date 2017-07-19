//
//  GRDiffParser.swift
//  GitReview
//
//  Created by Whitney Foster on 7/14/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation

func parseDiff(fileContents diff: String) throws -> [GRDiffFile] {
    let files = diff.components(separatedBy: "diff").filter({ $0.isEmpty == false }).map({ GRDiffFile($0) })
    guard
        files.isEmpty == false
    else {
        throw NSError.create(message: "Diff could not be parsed")
    }
    return files
}

struct GRDiffFile {
    let fileName: (String?, String?)
    let newFile: Bool
    private(set) var blocks: [GRFileChangeBlock] = []
    
    init(_ file: String) {
        var diffLines = file.components(separatedBy: "\n")
        
        let header = diffLines.removeFirst().components(separatedBy: " ").filter({ $0 != "diff" && $0 != "--git" }).filter({ $0.isEmpty == false })
        self.fileName = (header.first, header.last)
        
        self.newFile = diffLines.first?.contains("new file") ?? false
        
        while !(diffLines.first?.hasPrefix("@@") ?? true) {
            let _ = diffLines.removeFirst()
        }
        
        if diffLines.count > 0 {
            var currentLineNumber = getlineNumbers(diffLines.removeFirst())
            var lineCompare: [[String]] = [[], []]
            for line in diffLines {
                let currentLine = "\(line)\n"
                if currentLine.hasPrefix("@@") {
                    blocks.append(GRFileChangeBlock(lineNumber: currentLineNumber, text: lineCompare))
                    lineCompare = []
                    currentLineNumber = getlineNumbers(currentLine)
                }
                else {
                    if !currentLine.hasPrefix("+") {
                        lineCompare[0].append(currentLine)
                    }
                    if !currentLine.hasPrefix("-") {
                        lineCompare[1].append(currentLine)
                    }
                }
            }
            blocks.append(GRFileChangeBlock(lineNumber: currentLineNumber, text: lineCompare))
        }
    }
    
    private func getlineNumbers(_ str: String) -> [(start: Int?, totalLines: Int?)] {
        var components = str.components(separatedBy: CharacterSet(charactersIn: " "))
        var lineNumbers = [String]()
        while lineNumbers.count < 4 && components.isEmpty == false {
            lineNumbers.append(components.removeFirst())
        }
        var result: [(start: Int?, totalLines: Int?)] = []
        let lines = lineNumbers.filter({ $0.hasPrefix("@@") == false })
        for i in 0 ..< lines.count {
            var split = lines[i].components(separatedBy: ",")
            while split.count > 0 {
                if let first = split.first {
                    let _ = split.removeFirst()
                    if first.hasPrefix("-") || first.hasPrefix("+") {
                        result[i] = (Int(NSString(string: first).substring(from: 1)), nil)
                    }
                    else {
                        result[i] = (result[0].start, Int(first))
                    }
                }
            }

        }
        
        return result
        
    }
}

struct GRFileChangeBlock {
    let lineNumber: [(start: Int?, totalLines: Int?)]
    let text: [[String]]
}
