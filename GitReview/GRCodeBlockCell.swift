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
        
        let left = NSMutableAttributedString.lineOfFile(line: "").0
        let right = NSMutableAttributedString.lineOfFile(line: "").0

        self.diff?.blocks.forEach {
            (block) in
            var lineNumber: (Int, Int) = (block.lineNumber.start.0 ?? 0, block.lineNumber.start.1 ?? 0)
            left.append(NSMutableAttributedString.lineOfFile(line: " -- \n").0)
            right.append(NSMutableAttributedString.lineOfFile(line: " -- \n").0)
            block.text.forEach {
                (line) in
                let leftTxt = NSMutableAttributedString.lineOfFile(line: line.0)
                let rightTxt = NSMutableAttributedString.lineOfFile(line: line.1)
                left.append(NSMutableAttributedString.lineNumber(number: lineNumber.0, color: leftTxt.1))
                right.append(NSMutableAttributedString.lineNumber(number: lineNumber.1, color: rightTxt.1))
                left.append(leftTxt.0)
                right.append(rightTxt.0)
                lineNumber = (lineNumber.0 + 1, lineNumber.1 + 1)
            }
        }
        self.leftLabel.attributedText = left
        self.rightLabel.attributedText = right
    }
}

class GRCodeLineCompareCell: UITableViewCell {
    static let identifier = "linesCell"
    static let nibName = "GRCodeLineCompareCell"
    @IBOutlet weak var leftTextView: UITextView!
    @IBOutlet weak var rightTextView: UITextView!
    
    func setUp(left: String, right: String) {
        self.leftTextView.text = left
        self.rightTextView.text = right
        self.leftTextView.sizeToFit()
        self.rightTextView.sizeToFit()
    }
}
