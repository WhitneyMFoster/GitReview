//
//  GRPullRequestListViewController.swift
//  GitReview
//
//  Created by Whitney Foster on 7/16/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import UIKit

class GRPullRequestListViewController: UITableViewController {
    let tableManager: GRTableViewManager = GRTableViewManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = tableManager
        self.tableView.dataSource = tableManager
        
        self.loadPullRequests()
    }
    
    @IBAction func loadPullRequests() {
        if let repo = GRRepositoryManager.shared.repository {
            GRApiClient.shared.getPullRequests(forRepository: repo, completion: { [weak self] (error) in
                if let alert = error?.createAlert() {
                    self?.present(alert, animated: true, completion: nil)
                }
                self?.resetTable()
            })
        }
        else {
            GRApiClient.shared.getRepository(organization: "magicalpanda", repoName: "MagicalRecord") { [weak self] (error) in
                if let alert = error?.createAlert() {
                    self?.present(alert, animated: true, completion: nil)
                }
                self?.loadPullRequests()
            }
        }
    }
    
    private func resetTable() {
        tableManager.delegate = nil // todo
        var rows = [Row]()
        GRRepositoryManager.shared.repository?.pullRequests.forEach {
            (pr) in
            rows.append(Row(identifier: GRPullRequestCell.identifier, setUp: { (c) in
                if let cell = c as? GRPullRequestCell {
                    cell.setUp(pullRequest: pr)
                }
            }))
        }
        tableManager.tableSettings = TableViewSettings(sections: [Section(rows: rows)])
        self.tableView.reloadData()
        DispatchQueue.main.async(execute: { [weak self] () -> Void in
            self?.refreshControl?.endRefreshing()
        })
    }
}
