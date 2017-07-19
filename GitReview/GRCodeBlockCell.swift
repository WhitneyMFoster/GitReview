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
    static let identifier = "compareCell"

    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
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
        var sections: [[Section]] = [[], []]
        self.file?.blocks.forEach({ (block) in
            var j = 0
            while j < block.text.count && j < 2 {
                var lineNumber = block.lineNumber[j].start ?? 0
                let total = block.lineNumber[j].totalLines ?? 0
                var rows: [Row] = []
                block.text[j].forEach({ (line) in
                    rows.append(Row(identifier: GRLineCell.identifier, setUp: { (c) in
                        if let cell = c as? GRLineCell {
                            cell.setUp(line: lineNumber > total ? nil : lineNumber, text: line)
                        }
                    }))
                    lineNumber += 1
                })
                sections[j].append(Section(header: HeaderFooter(title: "---"), rows: rows))
                j += 1
            }
        })
        for k in 0 ... 1 {
            self.tableManager[k].tableSettings = TableViewSettings(sections: sections[k])
        }
        self.leftTableView.delegate = self.tableManager[0]
        self.rightTableView.delegate = self.tableManager[1]
        self.leftTableView.dataSource = self.tableManager[0]
        self.rightTableView.dataSource = self.tableManager[1]

        self.leftTableView.reloadData()
        self.rightTableView.reloadData()
    }
    
    
}
