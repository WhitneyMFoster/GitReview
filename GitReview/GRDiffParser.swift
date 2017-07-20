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
    private(set) var fileName: [String?] = []
    private(set) var blocks: [GRFileChangeBlock] = []
    
    init(_ file: String) {
        var diffLines = file.components(separatedBy: "\n")
        
        var currentLineNumber: [(start: Int?, totalLines: Int?)] = []
        var lineCompare: [[String]] = [[], []]
        while diffLines.isEmpty == false {
            let current = diffLines.removeFirst()
            if (current.hasPrefix("---") || current.hasPrefix("+++")) && current.characters.count > 4 {
                self.fileName.append(NSString(string: current).substring(from: 4))
            }
            else if current.hasPrefix("@@") {
                if currentLineNumber.isEmpty == false {
                    blocks.append(GRFileChangeBlock(lineNumber: currentLineNumber, text: lineCompare))
                }
                lineCompare = [[], []]
                currentLineNumber = GRFileChangeBlock.getlineNumbers(current)
            }
            else if currentLineNumber.isEmpty == false {
                if !current.hasPrefix("+") {
                    lineCompare[0].append(current)
                }
                if !current.hasPrefix("-") {
                    lineCompare[1].append(current)
                }
            }
        }
        blocks.append(GRFileChangeBlock(lineNumber: currentLineNumber, text: lineCompare))
        
    }
    
    
}

struct GRFileChangeBlock {
    let lineNumber: [(start: Int?, totalLines: Int?)]
    let text: [[String]]
    
    fileprivate static func getlineNumbers(_ str: String) -> [(start: Int?, totalLines: Int?)] {
        var result: [(start: Int?, totalLines: Int?)] = []
        for c in str.components(separatedBy: CharacterSet(charactersIn: " ")) {
            if c.hasPrefix("@@") {
                if result.isEmpty == false {
                    break
                }
            }
            else {
                let numbers = c.components(separatedBy: ",").map({
                    Int(NSString(string: $0).substring(from: ($0.hasPrefix("-") || $0.hasPrefix("+")) ? 1 : 0))
                })
                result.append((numbers.isEmpty ? nil : numbers[0], numbers.count < 2 ? nil : numbers[1]))
            }
        }
        
        return result
        
    }
}
