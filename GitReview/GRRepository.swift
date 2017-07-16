//
//  GRRepository.swift
//  GitReview
//
//  Created by Whitney Foster on 7/13/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import SwiftyJSON

class GRRepositoryManager {
    static let shared = GRRepositoryManager()
    var repository: GRRepository? = nil
    
    private init() { }
    
}

class GRRepository {
    let id: Int
    let name: String
    let owner: GRGitUser
    var pullRequests: [GRPullRequest] = []
    
    init(json: JSON) throws {
        guard
            let id = json["id"].int
            else {
                throw NSError.create(message: "Response could not be mapped to \(GRRepository.self)")
        }
        do {
        self.id = id
        self.name = json["name"].stringValue
        self.owner = try GRGitUser(json: json["owner"])
        }
        catch let error as NSError {
            throw error
        }
    }
    
    func setDiffFiles(files: [GRDiffFile], forPullRequest number: Int) {
        if let index = self.pullRequests.index(where: { $0.number == number }) {
            self.pullRequests[index].diffFiles = files
        }
    }
}

struct GRPullRequest {
    let id: Int
    let number: Int
    let user: GRGitUser
    let title: String
    let base: String
    let head: String
    let dateOpened: Date?
    var diffFiles: [GRDiffFile] = []
    
    init(json: JSON) throws {
        guard
            let id = json["id"].int,
            let number = json["number"].int,
            let base = json["base"]["label"].string,
            let head = json["head"]["label"].string
            else {
                throw NSError.create(message: "Response could not be mapped to \(GRPullRequest.self)")
        }
        do {
            self.id = id
            self.number = number
            self.user = try GRGitUser(json: json["user"])
            self.title = json["title"].stringValue
            self.base = base
            self.head = head
            self.dateOpened = json["created_at"].string?.toDate()
        }
        catch let error as NSError {
            throw error
        }
    }
}

struct GRGitUser {
    let id: Int
    let userName: String
    let profileImageURL: String?
    let type: String
    let isAdmin: Bool
    
    init(json: JSON) throws {
        guard
            let id = json["id"].int
        else {
            throw NSError.create(message: "Response could not be mapped to \(GRGitUser.self)")
        }
        self.id = id
        userName = json["login"].stringValue
        self.profileImageURL = json["avatar_url"].string
        self.type = json["type"].stringValue
        self.isAdmin = Bool(json["site_admin"].stringValue) ?? false
    }
}
