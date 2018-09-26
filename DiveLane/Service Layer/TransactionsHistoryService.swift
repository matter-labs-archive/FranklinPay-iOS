//
//  TransactionsHistoryService.swift
//  DiveLane
//
//  Created by NewUser on 14/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import BigInt

class TransactionsHistoryService {
    func loadTransactions(forAddress address: String, type: TransactionType, inNetwork networkId: Int64, completion: @escaping(Result<[ETHTransactionModel]>) -> Void) {
        guard let url = getURL(forType: type, address: address, networkId: networkId) else {
            completion(Result.Error(NetworkErrors.couldnotParseUrlString))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.Error(error))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(Result.Error(NetworkErrors.couldnotParseJSON))
                }
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    DispatchQueue.main.async {
                        completion(Result.Error(NetworkErrors.couldnotParseJSON))
                    }
                    return
                }
                guard let results = json["result"] as? [[String: Any]] else {
                    DispatchQueue.main.async {
                        completion(Result.Error(NetworkErrors.couldnotParseJSON))
                    }
                    return
                }
                var transactions = [ETHTransactionModel]()
                for result in results {
                    guard let from = result["from"] as? String,
                        let to = result["to"] as? String,
                        let timestamp = Double(result["timeStamp"] as! String),
                        let value = result["value"] as? String,
                        let hash = result["hash"] as? String,
                        let data = result["input"] as? String else {
                            DispatchQueue.main.async {
                                completion(Result.Error(NetworkErrors.couldnotParseJSON))
                            }
                            return
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
                    var tokenModel: ERC20TokenModel?
                    if type == .arbitraryMethodWithParams {
                        guard let tokenName = result["tokenName"] as? String,
                            let tokenSymbol = result["tokenSymbol"] as? String,
                            let tokenDecimal = result["tokenDecimal"] as? String,
                            let tokenAddress = result["contractAddress"] as? String else {
                                return
                        }
                        tokenModel = ERC20TokenModel(name: tokenName, address: tokenAddress, decimals: tokenDecimal, symbol: tokenSymbol)
                    } else {
                        tokenModel = nil
                    }
                    guard let amount = BigUInt(value) else { return }
                    guard let amountString = Web3.Utils.formatToEthereumUnits(amount) else { return }
                    let transaction = ETHTransactionModel(transactionHash: hash, from: from, to: to, amount: amountString, date: date, data: Data.fromHex(data), token: tokenModel, networkID: networkId, isPending: false)
                    transactions.append(transaction)
                }
                DispatchQueue.main.async {
                    completion(Result.Success(transactions))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(Result.Error(error))
                }
            }
        }
        dataTask.resume()
    }
    
}
