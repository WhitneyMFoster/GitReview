//
//  GRApiClient.swift
//  GitReview
//
//  Created by Whitney Foster on 7/14/17.
//  Copyright © 2017 Whitney Foster. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SVProgressHUD

class GRApiClient {
    static let shared = GRApiClient()
    private var sessionManager: SessionManager
    private let baseURL = "https://api.github.com/"
    private let diffURL = "https://github.com/"
    
    private enum Endpoint: String {
        case diff = "%@/%@/pull/%d.diff" //org, repo, prNumber
        case repository = "repos/%@/%@" //org, repo
        case pullRequests = "repos/%@/%@/pulls" //org, repo
        case pullRequest = "repos/%@/%@/pulls/%d" //org, repo, prNumber
    }
    
    private struct EndpointString {
        let value: String
        init(endPoint: Endpoint, arg: [CVarArg]) {
            self.value = String(format: endPoint.rawValue, arguments: arg)
        }
        
        init(endPoint: Endpoint) {
            self.value = endPoint.rawValue
        }
    }
    
    private init() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = [
            "Connection": "keep-alive",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type":	"application/json; charset=utf-8"
        ]
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.timeoutIntervalForRequest = 10
        sessionConfiguration.timeoutIntervalForResource = 10
        self.sessionManager = Alamofire.SessionManager(configuration: sessionConfiguration)
    }
    
    private func makeApiCall(method: HTTPMethod, endpoint: EndpointString, parameters: [String: Any]?, encoding: ParameterEncoding = JSONEncoding.default, success: @escaping (JSON) -> Void, failure: @escaping (NSError) -> Void) {
        SVProgressHUD.show(withStatus: "Loading...")
        self.sessionManager.request("\(baseURL)\(endpoint.value)", method: method, parameters: parameters, encoding: encoding, headers: nil).responseJSON { (response) in
            if response.result.isFailure || response.result.error != nil {
                let errorMessage = response.result.error?.localizedDescription ?? response.error?.localizedDescription ?? response.result.error?.localizedDescription ?? "Something went wrong"
                failure(NSError.create(message: errorMessage))
                SVProgressHUD.showError(withStatus: errorMessage)
            }
            else if let value = response.result.value {
                let json = JSON(value)
                success(json)
            }
            else {
                failure(NSError.create(message: "Nothing was returned"))
                SVProgressHUD.showError(withStatus: "Nothing was returned")
            }
        }
    }
    
    private func makeCall(method: HTTPMethod, endpoint: EndpointString, parameters: [String: Any]?, encoding: ParameterEncoding = JSONEncoding.default, success: @escaping (String) -> Void, failure: @escaping (NSError) -> Void) {
        SVProgressHUD.show(withStatus: "Loading...")
        self.sessionManager.request("\(diffURL)\(endpoint.value)", method: method, parameters: parameters, encoding: encoding, headers: nil).responseString { (response) in
            if response.result.isFailure || response.result.error != nil {
                let errorMessage = response.result.error?.localizedDescription ?? response.error?.localizedDescription ?? response.result.error?.localizedDescription ?? "Something went wrong"
                failure(NSError.create(message: errorMessage))
                SVProgressHUD.showError(withStatus: errorMessage)
            }
            else if let value = response.result.value {
                success(value)
            }
            else {
                failure(NSError.create(message: "Nothing was returned"))
                SVProgressHUD.showError(withStatus: "Nothing was returned")
            }
        }
    }
    
    func getRepository(organization: String, repoName: String, completion: @escaping (NSError?) -> Void) {
        self.makeApiCall(
            method: .get,
            endpoint: GRApiClient.EndpointString(endPoint: .repository, arg: [organization, repoName]),
            parameters: nil,
            success: { (json) in
                do {
                    GRRepositoryManager.shared.repository = try GRRepository(json: json)
                    completion(nil)
                }
                catch let e as NSError {
                    completion(e)
                }
                
        }) { (errorMessage) in
            completion(errorMessage)
        }
    }
    
    func getPullRequests(completion: @escaping (NSError?) -> Void) {
        guard let repository = GRRepositoryManager.shared.repository else {
            GRApiClient.shared.getRepository(organization: GRRepositoryManager.shared.organizationName, repoName: GRRepositoryManager.shared.repositoryName, completion: { (err) in
                guard err == nil else {
                    completion(err)
                    return
                }
                self.getPullRequests(completion: completion)
            })
            return
        }
        self.makeApiCall(
            method: .get,
            endpoint: GRApiClient.EndpointString(endPoint: .pullRequests, arg: [repository.owner.userName, repository.name]),
            parameters: nil,
            success: { (json) in
                var pullRequests = [GRPullRequest]()
                json.arrayValue.forEach({ (pr) in
                    do {
                        pullRequests.append(try GRPullRequest(json: pr))
                    }
                    catch {
                        // just ignore failing pr's
                    }
                })
                GRRepositoryManager.shared.repository?.pullRequests = pullRequests
                completion(nil)
        }) { (error) in
            completion(error)
        }
    }
    
    func getPullRequestInfo(forPullRequest pr: Int, completion: @escaping (NSError?) -> Void) {
        guard let repository = GRRepositoryManager.shared.repository else {
            GRApiClient.shared.getRepository(organization: GRRepositoryManager.shared.organizationName, repoName: GRRepositoryManager.shared.repositoryName, completion: { (err) in
                guard err == nil else {
                    completion(err)
                    return
                }
                self.getPullRequestInfo(forPullRequest: pr, completion: completion)
            })
            return
        }
        self.makeApiCall(
            method: .get,
            endpoint: GRApiClient.EndpointString(endPoint: .pullRequest, arg: [repository.owner.userName, repository.name, pr]),
            parameters: nil,
            success: { (json) in
                do {
                    GRRepositoryManager.shared.repository?.updatePullRequest(info: try GRPullRequest(json: json))
                    self.getDiff(forPullRequest: pr, completion: completion)
                }
                catch let e as NSError {
                    completion(e)
                }
        }) { (error) in
            completion(error)
        }
    }
    
    func getDiff(forPullRequest pr: Int, completion: @escaping (NSError?) -> Void) {
        guard let repository = GRRepositoryManager.shared.repository else {
            GRApiClient.shared.getRepository(organization: GRRepositoryManager.shared.organizationName, repoName: GRRepositoryManager.shared.repositoryName, completion: { (err) in
                guard err == nil else {
                    completion(err)
                    return
                }
                self.getDiff(forPullRequest: pr, completion: completion)
            })
            return
        }
        self.makeCall(
            method: .get,
            endpoint: GRApiClient.EndpointString(endPoint: .diff, arg: [repository.owner.userName, repository.name, pr]),
            parameters: nil,
            success: { (result) in
                do {
                    GRRepositoryManager.shared.repository?.setDiffFiles(files: try parseDiff(fileContents: result), forPullRequest: pr)
                    
                    completion(nil)
                }
                catch let e as NSError {
                    completion(e)
                }
        }) { (errorMessage) in
            completion(errorMessage)
        }
    }
    
}
