//
//  EtherscanService.swift
//  DiveLane
//
//  Created by Georgii Fesenko on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Alamofire
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
            Alamofire.request(url, method: .get).responseJSON { response in
                if let error = response.result.error {
                    seal.reject(error)
                    return
                }
                
                guard response.data != nil else {
                    seal.reject(Errors.NetworkErrors.noData)
                    return
                }
                
                guard let value = response.result.value as? [String: String] else {
                    seal.reject(Errors.NetworkErrors.wrongJSON)
                    return
                }
                
                guard let message = value["message"], message == "OK", let abi = value["result"] else {
                    seal.reject(Errors.NetworkErrors.noSuchAPIOnTheEtherscan)
                    return
                }
                seal.fulfill(abi)
            }
        }
        return returnPromise
    }
}
