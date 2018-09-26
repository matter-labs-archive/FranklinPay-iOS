//
//  EtherscanService.swift
//  DiveLane
//
//  Created by Georgii Fesenko on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

class EtherscanService {
    func getAbi(forContractAddress contractAddress: String, completion: @escaping(Result<String>) -> Void) {
        let urlString = getURL(forContractAddress: contractAddress)
        guard let url = URL(string: urlString) else {
            completion(Result.Error(NetworkErrors.couldnotParseUrlString))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: request) { (data, responce, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.Error(error))
                }
                return
            }
            if let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
                        DispatchQueue.main.async {
                            completion(Result.Error(NetworkErrors.couldnotParseJSON))
                        }
                        return
                    }
                    if let message = json["message"], message == "OK", let abi = json["result"] {
                        DispatchQueue.main.async {
                            completion(Result.Success(abi))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(Result.Error(NetworkErrors.noSuchAPIOnTheEtherscan))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(Result.Error(error))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(Result.Error(NetworkErrors.noSuchAPIOnTheEtherscan))
                }
            }
            
        }
        dataTask.resume()
        
    }
}

enum NetworkErrors: Error {
    case couldnotParseUrlString
    case couldnotParseJSON
    case noSuchAPIOnTheEtherscan
}
