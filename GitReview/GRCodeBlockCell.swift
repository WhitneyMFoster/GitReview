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
    var block: GRFileChangeBlock? = nil
    @IBOutlet weak var tableView: UITableView!
    let manager = GRTableViewManager()
    
    func setUp(block: GRFileChangeBlock) {
        self.block = block
        
        self.tableView.register(UINib(nibName: GRCodeLineCompareCell.nibName, bundle: Bundle.main), forCellReuseIdentifier: GRCodeLineCompareCell.identifier)
        self.tableView.delegate = manager
        self.tableView.dataSource = manager
        
//        DispatchQueue.global(qos: .background).async {
            var rows = [Row]()
            self.block?.text.forEach {
                (line) in
                rows.append(Row(identifier: GRCodeLineCompareCell.identifier, setUp: { (c) in
                    if let cell = c as? GRCodeLineCompareCell {
                        cell.setUp(left: line.0, right: line.1)
                    }
                }))
            }
            self.manager.tableSettings = TableViewSettings(sections: [Section(rows: rows)])
//        }
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
    }
}
