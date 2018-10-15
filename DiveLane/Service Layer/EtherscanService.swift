//
//  EtherscanService.swift
//  DiveLane
//
//  Created by Georgii Fesenko on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Alamofire

class EtherscanService {
    func getAbi(forContractAddress contractAddress: String, completion: @escaping(Result<String>) -> Void) {
        let urlString = getURL(forContractAddress: contractAddress)
        guard let url = URL(string: urlString) else {
            completion(Result.Error(NetworkErrors.couldnotParseUrlString))
            return
        }

		Alamofire.request(url, method: .get).responseJSON { response in
			guard response.result.isSuccess else {
				DispatchQueue.main.async {
					completion(Result.Error(response.result.error!))
				}
				return
			}

			guard response.data != nil else {
				DispatchQueue.main.async {
					completion(Result.Error(NetworkErrors.noSuchAPIOnTheEtherscan))
				}
				return
			}

			guard let value = response.result.value as? [String: String] else {
				DispatchQueue.main.async {
					completion(Result.Error(NetworkErrors.couldnotParseJSON))
				}
				return
			}

			guard let message = value["message"], message == "OK", let abi = value["result"] else {
				DispatchQueue.main.async {
					completion(Result.Error(NetworkErrors.noSuchAPIOnTheEtherscan))
				}
				return
			}
			DispatchQueue.main.async {
				completion(Result.Success(abi))
			}
		}
    }
}

enum NetworkErrors: Error {
    case couldnotParseUrlString
    case couldnotParseJSON
    case noSuchAPIOnTheEtherscan
}
