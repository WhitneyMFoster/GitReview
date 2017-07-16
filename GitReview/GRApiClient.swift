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

class GRApiClient {
    static let shared = GRApiClient()
    private var sessionManager: SessionManager
    private let baseURL = "https://api.github.com/"
    private let diffURL = "https://github.com/"
    
    private enum Endpoint: String {
        case diff = "%@/%@/pull/%d.diff" //org, repo, prNumber
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
    
    private func makeApiCall(method: HTTPMethod, endpoint: EndpointString, parameters: [String: Any]?, encoding: ParameterEncoding = JSONEncoding.default, success: @escaping (JSON) -> Void, failure: @escaping (String) -> Void) {
        self.sessionManager.request("\(baseURL)\(endpoint.value)", method: method, parameters: parameters, encoding: encoding, headers: nil).responseJSON { (response) in
            if response.result.isFailure || response.result.error != nil {
                let errorMessage = response.result.error?.localizedDescription ?? response.error?.localizedDescription ?? response.result.error?.localizedDescription ?? "Something went wrong"
                failure(errorMessage)
            }
            else if let value = response.result.value {
                let json = JSON(value)
                success(json)
            }
            else {
                failure("Nothing was returned")
            }
        }
    }
    
    private func makeCall(method: HTTPMethod, endpoint: EndpointString, parameters: [String: Any]?, encoding: ParameterEncoding = JSONEncoding.default, success: @escaping (String) -> Void, failure: @escaping (String) -> Void) {
        self.sessionManager.request("\(diffURL)\(endpoint.value)", method: method, parameters: parameters, encoding: encoding, headers: nil).responseString { (response) in
            if response.result.isFailure || response.result.error != nil {
                let errorMessage = response.result.error?.localizedDescription ?? response.error?.localizedDescription ?? response.result.error?.localizedDescription ?? "Something went wrong"
                failure(errorMessage)
            }
            else if let value = response.result.value {
                success(value)
            }
            else {
                failure("Nothing was returned")
            }
        }
    }
    
    func getDiff() {
        self.makeCall(method: .get, endpoint: GRApiClient.EndpointString(endPoint: .diff, arg: ["magicalpanda", "MagicalRecord", 1305]), parameters: nil, success: { (result) in
            NSLog(result)
            let parsed = GRDiffParser(fileContents: result)
            print()
        }) { (errorMessage) in
            NSLog(errorMessage)
        }
    }

}
