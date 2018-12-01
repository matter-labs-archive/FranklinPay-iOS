//
//  TransactionsHistoryService.swift
//  DiveLane
//
//  Created by NewUser on 14/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol ITransactionsHistoryService {
    func loadTransactions(for address: String,
                          txType: TransactionType?,
                          networkId: Int64) throws -> [ETHTransactionModel]
}

public class TransactionsHistoryService: ITransactionsHistoryService {
    
    private func buildTXlist(from results: [[String: Any]],
                             txType: TransactionType,
                             networkId: Int64) throws -> [ETHTransactionModel] {
        var transactions = [ETHTransactionModel]()
        for result in results {
            guard let from = result["from"] as? String,
                let to = result["to"] as? String,
                let timestamp = Double((result["timeStamp"] as? String)!),
                let value = result["value"] as? String,
                let hash = result["hash"] as? String,
                let data = result["input"] as? String else {
                    throw Errors.NetworkErrors.wrongJSON
            }
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            var tokenModel: ERC20TokenModel?
            if txType == .arbitraryMethodWithParams {
                guard let tokenName = result["tokenName"] as? String,
                    let tokenSymbol = result["tokenSymbol"] as? String,
                    let tokenDecimal = result["tokenDecimal"] as? String,
                    let tokenAddress = result["contractAddress"] as? String else {
                        throw Errors.NetworkErrors.wrongJSON
                }
                tokenModel = ERC20TokenModel(name: tokenName,
                                             address: tokenAddress,
                                             decimals: tokenDecimal,
                                             symbol: tokenSymbol)
            } else {
                tokenModel = nil
            }
            guard let amount = BigUInt(value) else {
                throw Errors.NetworkErrors.wrongJSON
            }
            guard let amountString = Web3.Utils.formatToEthereumUnits(amount) else {
                throw Errors.NetworkErrors.wrongJSON
            }
            let transaction = ETHTransactionModel(transactionHash: hash,
                                                  from: from,
                                                  to: to,
                                                  amount: amountString,
                                                  date: date,
                                                  data: Data.fromHex(data),
                                                  token: tokenModel,
                                                  networkID: networkId,
                                                  isPending: false)
            transactions.append(transaction)
        }
        return transactions
    }
    
    public func loadTransactions(for address: String,
                                 txType: TransactionType?,
                                 networkId: Int64) throws -> [ETHTransactionModel] {
        let type = txType ?? .arbitraryMethodWithParams
        return try self.loadTransactionsPromise(for: address, txType: type, networkId: networkId).wait()
    }
    
    private func loadTransactionsPromise(for address: String,
                                        txType: TransactionType,
                                        networkId: Int64) -> Promise<[ETHTransactionModel]> {
        let returnPromise = Promise<[ETHTransactionModel]> { (seal) in
            guard let url = URLs().getEtherscanURL(for: txType, address: address, networkId: networkId) else {
                seal.reject(Errors.NetworkErrors.wrongURL)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    seal.reject(error)
                }
                guard let data = data else {
                    seal.reject(Errors.NetworkErrors.noData)
                    return
                }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    guard let results = json["result"] as? [[String: Any]] else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    do {
                        let transaction = try self.buildTXlist(from: results,
                                                               txType: txType,
                                                               networkId: networkId)
                        seal.fulfill(transaction)
                    } catch let err {
                        seal.reject(err)
                    }
                } catch let err {
                    seal.reject(err)
                }
            }
            dataTask.resume()
        }
        return returnPromise
    }
}
