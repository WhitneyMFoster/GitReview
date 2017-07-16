//
//  GRPullRequestCell.swift
//  GitReview
//
//  Created by Whitney Foster on 7/16/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import UIKit

class GRPullRequestCell: UITableViewCell {
    static let identifier = "prCell"
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var prTitleLabel: UILabel!
    @IBOutlet weak var prSubtitleLabel: UILabel!
    
    func setUp(pullRequest: GRPullRequest) {
        userImageView.setImageWithCache(urlString: pullRequest.user.profileImageURL, completion: nil)
        prTitleLabel.text = pullRequest.title
        let date = pullRequest.dateOpened == nil ? "" : " opened on \(pullRequest.dateOpened!.toString())"
        prSubtitleLabel.text = "#\(pullRequest.number)" + date + " by \(pullRequest.user.userName)"
    }
}
