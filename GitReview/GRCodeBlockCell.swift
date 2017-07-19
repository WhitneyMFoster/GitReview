//
//  GRCodeBlockCell.swift
//  GitReview
//
//  Created by Whitney Foster on 7/16/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import UIKit

//class GRCodeBlockCell: UITableViewCell {
//    static let identifier = "codeCell"
//    var diff: GRDiffFile? = nil
//    @IBOutlet weak var leftLabel: UILabel!
//    @IBOutlet weak var rightLabel: UILabel!
//    
//    func setUp(diff: GRDiffFile) {
//        self.diff = diff
//        
//        let left = NSMutableAttributedString.lineOfFile(line: "").0
//        let right = NSMutableAttributedString.lineOfFile(line: "").0
//
//        self.diff?.blocks.forEach {
//            (block) in
//            var lineNumber: (Int, Int) = (block.lineNumber.start.0 ?? 0, block.lineNumber.start.1 ?? 0)
//            left.append(NSMutableAttributedString.lineOfFile(line: " -- \n").0)
//            right.append(NSMutableAttributedString.lineOfFile(line: " -- \n").0)
//            block.text.forEach {
//                (line) in
//                let leftTxt = NSMutableAttributedString.lineOfFile(line: line.0)
//                let rightTxt = NSMutableAttributedString.lineOfFile(line: line.1)
//                left.append(NSMutableAttributedString.lineNumber(number: lineNumber.0, color: leftTxt.1))
//                right.append(NSMutableAttributedString.lineNumber(number: lineNumber.1, color: rightTxt.1))
//                left.append(leftTxt.0)
//                right.append(rightTxt.0)
//                lineNumber = (lineNumber.0 + 1, lineNumber.1 + 1)
//            }
//        }
//        self.leftLabel.attributedText = left
//        self.rightLabel.attributedText = right
//    }
//}

class GRLineCompareCell: UITableViewCell {
    static let identifier = "linesCell"
    static let nibName = "GRLineCompareCell"
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTextView: UITableView!
    private var tableManager: [GRTableViewManager] = [GRTableViewManager(), GRTableViewManager()]
    private var file: GRDiffFile? = nil
    var locked: Bool = true {
        didSet {
            // TODO: set scrolling enabled for both, then lock main table
        }
    }
    
    func setUp(file: GRDiffFile) {
        self.file = file
        DispatchQueue.main.async(execute: { [weak self] () -> Void in
            self?.reloadTables()
        })
    }
        
    private func reloadTables() {
        var i = 0
        self.file?.blocks.forEach({ (block) in
            var sections: [Section] = []
            var j = 0
            while j < block.text.count && i < 2 {
                var rows: [Row] = []
                block.text[j].forEach({ (line) in
                    rows.append(Row(identifier: "todo", setUp: { (c) in
                        // TODO
                    }))
                })
                sections.append(Section(header: HeaderFooter(title: "---"), rows: rows))
                j += 1
            }
            self.tableManager[i] = GRTableViewManager(settings: TableViewSettings(sections: sections))
            i += 1
        })
        self.leftTableView.reloadData()
        self.rightTextView.reloadData()
    }
    
    
}
