//
//  GRPullRequestDetailViewController.swift
//  GitReview
//
//  Created by Whitney Foster on 7/16/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import UIKit

class GRPullRequestDetailViewController: UITableViewController {
    var pullRequestNumber: Int?
    let tableManager: GRTableViewManager = GRTableViewManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = tableManager
        self.tableView.dataSource = tableManager
        
        self.loadPullRequest()
    }
    
    @IBAction func loadPullRequest() {
        guard let prNumber = pullRequestNumber else {
            let alert = NSError.create(message: "Pull Request could not be found.").createAlert()
            self.present(alert, animated: true, completion: nil)
            return
        }
        GRApiClient.shared.getPullRequestInfo(forPullRequest: prNumber) { [weak self] (error) in
            if let alert = error?.createAlert() {
                self?.present(alert, animated: true, completion: nil)
            }
            self?.resetTable()
        }
    }
    
    private func resetTable() {
        tableManager.delegate = nil
        let files = GRRepositoryManager.shared.repository?.getPullRequest(number: self.pullRequestNumber!)?.diffFiles
        var sections = [Section]()
        files?.forEach {
            (file) in
            sections.append(Section(header: HeaderFooter(title: file.fileName.1!), rows: [Row(identifier: GRLineCompareCell.identifier, setUp: { (c) in
                if let cell = c as? GRLineCompareCell {
                    cell.setUp(file: file)
                }
            })]))
        }
        
        tableManager.tableSettings = TableViewSettings(sections: sections)
        self.tableView.reloadData()
        DispatchQueue.main.async(execute: { [weak self] () -> Void in
            self?.refreshControl?.endRefreshing()
        })
    }
}
