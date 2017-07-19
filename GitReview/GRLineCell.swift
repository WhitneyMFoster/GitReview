//
//  GRLineCell.swift
//  GitReview
//
//  Created by Whitney Foster on 7/18/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import UIKit

class GRLineCell: UITableViewCell {
    static let identifier = "lineCell"
    
    @IBOutlet weak var lineNumberLabel: UILabel!
    @IBOutlet weak var lineContentLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    func setUp(line: Int?, text: String?) {
        self.lineNumberLabel.text = line == nil ? "" : "\(line!)"
        self.lineContentLabel.text = text
    }
}
