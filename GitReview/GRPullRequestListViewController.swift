//
//  GRPullRequestListViewController.swift
//  GitReview
//
//  Created by Whitney Foster on 7/16/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class GRPullRequestListViewController: UITableViewController {
    let tableManager: GRTableViewManager = GRTableViewManager()
    internal var selectedPr: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = tableManager
        self.tableView.dataSource = tableManager
        
        self.loadPullRequests()
    }
    
    @IBAction func loadPullRequests() {
        GRApiClient.shared.getPullRequests() { [weak self] (error) in
            if let alert = error?.createAlert() {
                self?.present(alert, animated: true, completion: nil)
            }
            self?.resetTable()
        }
    }
    
    private func resetTable() {
        tableManager.delegate = self
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
            SVProgressHUD.dismiss()
            self?.refreshControl?.endRefreshing()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let id = segue.identifier
        else {
            return
        }
        
        switch id {
            case "detail":
                let detailVC = (segue.destination as? UINavigationController)?.viewControllers.first as? GRPullRequestDetailViewController
                detailVC?.pullRequestNumber = self.selectedPr
                self.selectedPr = nil
            break
        default:
            break
        }
    }
}

extension GRPullRequestListViewController: GRTableViewManagerDelegate {
    func cellSelected(cell: UITableViewCell?, atIndex index: IndexPath) {
        if let pullRequests = GRRepositoryManager.shared.repository?.pullRequests, pullRequests.count > index.row {
            self.selectedPr = pullRequests[index.row].number
            OperationQueue.main.addOperation {
                [weak self] in
                self?.performSegue(withIdentifier: "detail", sender: self)
            }
        }
    }
}
