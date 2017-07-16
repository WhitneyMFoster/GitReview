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
            var changeLines: ([String], [String]) = ([], [])
            var lineCompare: [(String, String)] = []
            for line in diffLines {
                let currentLine = line
                if currentLine.hasPrefix("@@") {
                    blocks.append(GRFileChangeBlock(lineNumber: (currentLineNumber.0, currentLineNumber.1), text: lineCompare))
                    changeLines = ([], [])
                    lineCompare = []
                    currentLineNumber = getlineNumbers(currentLine)
                }
                else if changeLines.0.count == currentLineNumber.totalLines.0 && changeLines.1.count == currentLineNumber.totalLines.1 {
                    
                }
                else {
                    var compare = ("", "")
                    if currentLine.hasPrefix("-") {
                        compare.0 = currentLine
                        changeLines.0.append(currentLine)
                    }
                    else if currentLine.hasPrefix("+") {
                        compare.1 = currentLine
                        changeLines.1.append(currentLine)
                    }
                    else {
                        compare = (currentLine, currentLine)
                        changeLines.0.append(currentLine)
                        changeLines.1.append(currentLine)
                    }
                    lineCompare.append(compare)
                }
            }
            blocks.append(GRFileChangeBlock(lineNumber: (currentLineNumber.0, currentLineNumber.1), text: lineCompare))
        }
    }
    
    private func getlineNumbers(_ str: String) -> (start: (Int?, Int?), totalLines: (Int?, Int?), remainder: String?) {
        var components = str.components(separatedBy: CharacterSet(charactersIn: " "))
        var lineNumbers = [String]()
        while lineNumbers.count < 4 && components.isEmpty == false {
            lineNumbers.append(components.removeFirst())
        }
        var result: (start: (Int?, Int?), totalLines: (Int?, Int?), remainder: String?) = ((nil, nil), (nil, nil), components.joined(separator: " "))
        let lines = lineNumbers.filter({ $0.hasPrefix("@@") == false })
        for i in 0 ..< lines.count {
            var split = lines[i].components(separatedBy: ",")
            while split.count > 0 {
                if let first = split.first {
                    let _ = split.removeFirst()
                    if i == 0 {
                        if first.hasPrefix("-") {
                            result.start.0 = Int(NSString(string: first).substring(from: 1))! * -1
                        }
                        else {
                            result.totalLines.0 = Int(first)
                        }
                    }
                    else {
                        if first.hasPrefix("-") {
                            result.start.1 = Int(NSString(string: first).substring(from: 1))! * -1
                        }
                        else {
                            result.totalLines.1 = Int(first)
                        }
                    }
                }
            }

        }
        
        return result
        
    }
}

struct GRFileChangeBlock {
    let lineNumber: (start: (Int?, Int?), totalLines: (Int?, Int?))
    let text: [(String, String)]
}
