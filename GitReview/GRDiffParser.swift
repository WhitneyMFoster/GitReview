//
//  GRDiffParser.swift
//  GitReview
//
//  Created by Whitney Foster on 7/14/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation

struct GRDiffParser {
    var files: [GRDiffFile] = []
    
    init(fileContents diff: String) {
        files = diff.components(separatedBy: "diff").filter({ $0.isEmpty == false }).map({ GRDiffFile($0) })
    }
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
            for line in diffLines {
                let currentLine = line
                if currentLine.hasPrefix("@@") {
                    blocks.append(GRFileChangeBlock(lineNumber: (currentLineNumber.0, currentLineNumber.1), text: changeLines))
                    changeLines = ([], [])
                    currentLineNumber = getlineNumbers(currentLine)
                }
                else if changeLines.0.count == currentLineNumber.totalLines.0 && changeLines.1.count == currentLineNumber.totalLines.1 {
                    
                }
                else {
                    if currentLine.hasPrefix("-") {
                        changeLines.0.append(currentLine)
                    }
                    else if currentLine.hasPrefix("+") {
                        changeLines.1.append(currentLine)
                    }
                    else {
                        changeLines.0.append(currentLine)
                        changeLines.1.append(currentLine)
                    }
                }
            }
            blocks.append(GRFileChangeBlock(lineNumber: (currentLineNumber.0, currentLineNumber.1), text: changeLines))
        }
    }
    
    private func getlineNumbers(_ str: String) -> (start: (Int?, Int?), totalLines: (Int?, Int?), remainder: String?) {
        var components = str.components(separatedBy: CharacterSet(charactersIn: " "))
        var lineNumbers = [String]()
        while lineNumbers.count < 4 && components.isEmpty == false {
            lineNumbers.append(components.removeFirst())
        }
        var lines = lineNumbers.map({ NSString(string: $0).substring(from: 1) }).joined(separator: ",").components(separatedBy: ",").filter({ $0 != "@" })
        var result: (start: (Int?, Int?), totalLines: (Int?, Int?), remainder: String?) = ((nil, nil), (nil, nil), components.joined(separator: " "))
        result.start.0 = Int(lines.removeFirst())
        result.totalLines.0 = Int(lines.removeFirst())
        result.start.1 = Int(lines.removeFirst())
        result.totalLines.1 = Int(lines.removeFirst())
        
        return result
        
    }
}

struct GRFileChangeBlock {
    let lineNumber: (start: (Int?, Int?), totalLines: (Int?, Int?))
    let text: ([String], [String])
}
/*
 diff --git a/CHANGELOG.md b/CHANGELOG.md
 index fc27b82d..82b2a557 100644
 --- a/CHANGELOG.md
 +++ b/CHANGELOG.md
 @@ -46,7 +46,7 @@
 */
