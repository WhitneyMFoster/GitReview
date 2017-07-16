//
//  GRRepository.swift
//  GitReview
//
//  Created by Whitney Foster on 7/13/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import SwiftyJSON

class GRRepository {
    let id: Int
    let name: String
    let owner: GRRepositoryOwner
    
    init(json: JSON) throws {
        guard
            let id = json["id"].int
            else {
                throw NSError()
        }
        do {
        self.id = id
        self.name = json["name"].stringValue
        self.owner = try GRRepositoryOwner(json: json["owner"])
        }
        catch let error as NSError {
            throw error
        }
    }
    
}

struct GRRepositoryOwner {
    let id: Int
    let userName: String
    let profileImageURL: URL?
    let type: String
    let isAdmin: Bool
    
    init(json: JSON) throws {
        guard
            let id = json["id"].int
        else {
            throw NSError()
        }
        self.id = id
        userName = json["login"].stringValue
        let imageURLString = json["avatar_url"].string
        self.profileImageURL = imageURLString == nil ? nil : URL(string: imageURLString!)
        self.type = json["type"].stringValue
        self.isAdmin = Bool(json["site_admin"].stringValue) ?? false
    }
    
}

/*
 {
 "id": 417862,
 "name": "octokit.rb",
 "full_name": "octokit/octokit.rb",
 "owner": {
 "login": "octokit",
 "id": 3430433,
 "avatar_url": "https://avatars4.githubusercontent.com/u/3430433?v=4",
 "gravatar_id": "",
 "url": "https://api.github.com/users/octokit",
 "html_url": "https://github.com/octokit",
 "followers_url": "https://api.github.com/users/octokit/followers",
 "following_url": "https://api.github.com/users/octokit/following{/other_user}",
 "gists_url": "https://api.github.com/users/octokit/gists{/gist_id}",
 "starred_url": "https://api.github.com/users/octokit/starred{/owner}{/repo}",
 "subscriptions_url": "https://api.github.com/users/octokit/subscriptions",
 "organizations_url": "https://api.github.com/users/octokit/orgs",
 "repos_url": "https://api.github.com/users/octokit/repos",
 "events_url": "https://api.github.com/users/octokit/events{/privacy}",
 "received_events_url": "https://api.github.com/users/octokit/received_events",
 "type": "Organization",
 "site_admin": false
 },
 "private": false,
 "html_url": "https://github.com/octokit/octokit.rb",
 "description": "Ruby toolkit for the GitHub API",
 "fork": false,
 "url": "https://api.github.com/repos/octokit/octokit.rb",
 "forks_url": "https://api.github.com/repos/octokit/octokit.rb/forks",
 "keys_url": "https://api.github.com/repos/octokit/octokit.rb/keys{/key_id}",
 "collaborators_url": "https://api.github.com/repos/octokit/octokit.rb/collaborators{/collaborator}",
 "teams_url": "https://api.github.com/repos/octokit/octokit.rb/teams",
 "hooks_url": "https://api.github.com/repos/octokit/octokit.rb/hooks",
 "issue_events_url": "https://api.github.com/repos/octokit/octokit.rb/issues/events{/number}",
 "events_url": "https://api.github.com/repos/octokit/octokit.rb/events",
 "assignees_url": "https://api.github.com/repos/octokit/octokit.rb/assignees{/user}",
 "branches_url": "https://api.github.com/repos/octokit/octokit.rb/branches{/branch}",
 "tags_url": "https://api.github.com/repos/octokit/octokit.rb/tags",
 "blobs_url": "https://api.github.com/repos/octokit/octokit.rb/git/blobs{/sha}",
 "git_tags_url": "https://api.github.com/repos/octokit/octokit.rb/git/tags{/sha}",
 "git_refs_url": "https://api.github.com/repos/octokit/octokit.rb/git/refs{/sha}",
 "trees_url": "https://api.github.com/repos/octokit/octokit.rb/git/trees{/sha}",
 "statuses_url": "https://api.github.com/repos/octokit/octokit.rb/statuses/{sha}",
 "languages_url": "https://api.github.com/repos/octokit/octokit.rb/languages",
 "stargazers_url": "https://api.github.com/repos/octokit/octokit.rb/stargazers",
 "contributors_url": "https://api.github.com/repos/octokit/octokit.rb/contributors",
 "subscribers_url": "https://api.github.com/repos/octokit/octokit.rb/subscribers",
 "subscription_url": "https://api.github.com/repos/octokit/octokit.rb/subscription",
 "commits_url": "https://api.github.com/repos/octokit/octokit.rb/commits{/sha}",
 "git_commits_url": "https://api.github.com/repos/octokit/octokit.rb/git/commits{/sha}",
 "comments_url": "https://api.github.com/repos/octokit/octokit.rb/comments{/number}",
 "issue_comment_url": "https://api.github.com/repos/octokit/octokit.rb/issues/comments{/number}",
 "contents_url": "https://api.github.com/repos/octokit/octokit.rb/contents/{+path}",
 "compare_url": "https://api.github.com/repos/octokit/octokit.rb/compare/{base}...{head}",
 "merges_url": "https://api.github.com/repos/octokit/octokit.rb/merges",
 "archive_url": "https://api.github.com/repos/octokit/octokit.rb/{archive_format}{/ref}",
 "downloads_url": "https://api.github.com/repos/octokit/octokit.rb/downloads",
 "issues_url": "https://api.github.com/repos/octokit/octokit.rb/issues{/number}",
 "pulls_url": "https://api.github.com/repos/octokit/octokit.rb/pulls{/number}",
 "milestones_url": "https://api.github.com/repos/octokit/octokit.rb/milestones{/number}",
 "notifications_url": "https://api.github.com/repos/octokit/octokit.rb/notifications{?since,all,participating}",
 "labels_url": "https://api.github.com/repos/octokit/octokit.rb/labels{/name}",
 "releases_url": "https://api.github.com/repos/octokit/octokit.rb/releases{/id}",
 "deployments_url": "https://api.github.com/repos/octokit/octokit.rb/deployments",
 "created_at": "2009-12-10T21:41:49Z",
 "updated_at": "2017-07-14T20:42:46Z",
 "pushed_at": "2017-07-14T02:32:58Z",
 "git_url": "git://github.com/octokit/octokit.rb.git",
 "ssh_url": "git@github.com:octokit/octokit.rb.git",
 "clone_url": "https://github.com/octokit/octokit.rb.git",
 "svn_url": "https://github.com/octokit/octokit.rb",
 "homepage": "http://octokit.github.io/octokit.rb/",
 "size": 12774,
 "stargazers_count": 2656,
 "watchers_count": 2656,
 "language": "Ruby",
 "has_issues": true,
 "has_projects": true,
 "has_downloads": true,
 "has_wiki": false,
 "has_pages": true,
 "forks_count": 754,
 "mirror_url": null,
 "open_issues_count": 21,
 "forks": 754,
 "open_issues": 21,
 "watchers": 2656,
 "default_branch": "master",
 "organization": {
 "login": "octokit",
 "id": 3430433,
 "avatar_url": "https://avatars4.githubusercontent.com/u/3430433?v=4",
 "gravatar_id": "",
 "url": "https://api.github.com/users/octokit",
 "html_url": "https://github.com/octokit",
 "followers_url": "https://api.github.com/users/octokit/followers",
 "following_url": "https://api.github.com/users/octokit/following{/other_user}",
 "gists_url": "https://api.github.com/users/octokit/gists{/gist_id}",
 "starred_url": "https://api.github.com/users/octokit/starred{/owner}{/repo}",
 "subscriptions_url": "https://api.github.com/users/octokit/subscriptions",
 "organizations_url": "https://api.github.com/users/octokit/orgs",
 "repos_url": "https://api.github.com/users/octokit/repos",
 "events_url": "https://api.github.com/users/octokit/events{/privacy}",
 "received_events_url": "https://api.github.com/users/octokit/received_events",
 "type": "Organization",
 "site_admin": false
 },
 "network_count": 754,
 "subscribers_count": 169
 }
 */
