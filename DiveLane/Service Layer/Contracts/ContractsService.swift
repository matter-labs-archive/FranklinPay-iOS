//
//  EtherscanService.swift
//  DiveLane
//
//  Created by Georgii Fesenko on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IContractsService {
    func getAbi(for contractAddress: String) throws -> String
}

public class ContractsService: IContractsService {
    
    public func getAbi(for contractAddress: String) throws -> String {
        return try self.getAbi(for: contractAddress).wait()
    }
    
    private func getAbi(for contractAddress: String) -> Promise<String> {
        let returnPromise = Promise<String> { (seal) in
            let urlString = URLs().getContractURL(for: contractAddress)
            guard let url = URL(string: urlString) else {
                seal.reject(Errors.NetworkErrors.wrongURL)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    seal.reject(error)
                }
                if let data = data {
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
                            seal.reject(Errors.NetworkErrors.wrongJSON)
                            return
                        }
                        if let message = json["message"], message == "OK", let abi = json["result"] {
                            seal.fulfill(abi)
                        } else {
                            seal.reject(Errors.NetworkErrors.noSuchAPIOnTheEtherscan)
                        }
                    } catch let err {
                        seal.reject(err)
                    }
                } else {
                    seal.reject(Errors.NetworkErrors.noData)
                }
                
            }
            dataTask.resume()
        }
        return returnPromise
    }
}
