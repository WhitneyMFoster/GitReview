//
//  GRCodeBlockCell.swift
//  GitReview
//
//  Created by Whitney Foster on 7/16/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import UIKit

class GRCodeBlockCell: UITableViewCell {
    static let identifier = "codeCell"
    var diff: GRDiffFile? = nil
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    func setUp(diff: GRDiffFile) {
        self.diff = diff
        
        let lines: [NSMutableAttributedString] = [NSMutableAttributedString(string: ""), NSMutableAttributedString(string: "")]

        self.diff?.blocks.forEach {
            (block) in
            for i in 0 ... 1 {
                var lineNumber = block.lineNumber[i].start ?? 0
                lines[i].append(NSMutableAttributedString.lineOfFile(line: " -- ").0)
                block.text[i].forEach({ (line) in
                    let formattedLine = NSMutableAttributedString.lineOfFile(line: line)
                    lines[i].append(NSMutableAttributedString.lineNumber(number: lineNumber, color: formattedLine.1))
                    lines[i].append(formattedLine.0)
                    lineNumber += 1
                })
            }
        }
        self.leftLabel.attributedText = lines[0]
        self.rightLabel.attributedText = lines[1]
    }
}

//class GRLineCompareCell: UITableViewCell {
//    static let identifier = "linesCell"
//    static let nibName = "GRLineCompareCell"
//    @IBOutlet weak var leftTableView: UITableView!
//    @IBOutlet weak var rightTextView: UITableView!
//    private var tableManager: [GRTableViewManager] = [GRTableViewManager(), GRTableViewManager()]
//    private var file: GRDiffFile? = nil
//    var locked: Bool = true {
//        didSet {
//            // TODO: set scrolling enabled for both, then lock main table
//        }
//    }
//    
//    func setUp(file: GRDiffFile) {
//        self.file = file
//        DispatchQueue.main.async(execute: { [weak self] () -> Void in
//            self?.reloadTables()
//        })
//    }
//        
//    private func reloadTables() {
//        var i = 0
//        self.file?.blocks.forEach({ (block) in
//            var sections: [Section] = []
//            var j = 0
//            while j < block.text.count && i < 2 {
//                var rows: [Row] = []
//                block.text[j].forEach({ (line) in
//                    rows.append(Row(identifier: "todo", setUp: { (c) in
//                        // TODO
//                    }))
//                })
//                sections.append(Section(header: HeaderFooter(title: "---"), rows: rows))
//                j += 1
//            }
//            self.tableManager[i] = GRTableViewManager(settings: TableViewSettings(sections: sections))
//            i += 1
//        })
//        self.leftTableView.reloadData()
//        self.rightTextView.reloadData()
//    }
//    
//    
//}
