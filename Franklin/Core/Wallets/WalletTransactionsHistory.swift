//
//  WalletTransactionsHistory.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import CoreData
import BigInt
import Web3swift
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IWalletTransactionsHistory {
    func loadTransactions(txType: TransactionType?,
                          network: Web3Network) throws -> [ETHTransaction]
    func save(transactions: [ETHTransaction]) throws
    func getAllTransactions(for network: Web3Network) throws -> [ETHTransaction]
}

extension Wallet: IWalletTransactionsHistory {
    
    func save(transactions: [ETHTransaction]) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            do {
                for transaction in transactions {
                    let fr: NSFetchRequest<ETHTransactionModel> = ETHTransactionModel.fetchRequest()
                    fr.predicate = NSPredicate(format: "transactionHash = %@", transaction.transactionHash)
                    let result = try context.fetch(fr).first
                    if let result = result {
                        result.amount = transaction.amount
                        result.data = transaction.data
                        result.date = transaction.date
                        result.from = transaction.from
                        result.networkId = transaction.networkId
                        result.to = transaction.to
                        result.isPending = false
                        //Update information stored in local storage.
                    } else {
                        guard let newTransaction = NSEntityDescription.insertNewObject(forEntityName: "ETHTransactionModel", into: context) as? ETHTransactionModel else {
                            error = Errors.WalletErrors.cantSaveTx
                            group.leave()
                            return
                        }
                        newTransaction.amount = transaction.amount
                        newTransaction.data = transaction.data
                        newTransaction.date = transaction.date
                        newTransaction.from = transaction.from
                        newTransaction.networkId = transaction.networkId
                        newTransaction.to = transaction.to
                        newTransaction.isPending = false
                        
                        if let contractAddress = transaction.token?.address {
                            //In case of ERC20 tokens
                            let result = try context.fetch(self.fetchTokenRequest(withAddress: contractAddress)).first
                            if let token = result {
                                newTransaction.token = token
                            } else {
                                let newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20TokenModel", into: context) as? ERC20TokenModel
                                newToken?.address = transaction.token?.address
                                newToken?.decimals = transaction.token?.decimals
                                newToken?.name = transaction.token?.name
                                newToken?.symbol = transaction.token?.symbol
                                newToken?.networkId = transaction.networkId
                                newTransaction.token = newToken
                            }
                        } else {
                            //In case of custom ETH transaction
                            let result = try context.fetch(self.fetchTokenRequest(withAddress: ""))
                            if let ethToken = result.first {
                                newTransaction.token = ethToken
                            } else {
                                let newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20TokenModel", into: context) as? ERC20TokenModel
                                newToken?.address = ""
                                newToken?.name = "Ether"
                                newToken?.decimals = "18"
                                newToken?.symbol = "ETH"
                                newTransaction.token = newToken
                            }
                            
                        }
                        newTransaction.transactionHash = transaction.transactionHash
                        // MARK: - Fetch wallet from core data, and if there is no one wallet - create.
                        let walletCD = try context.fetch(self.fetchWalletRequest(with: self.address)).first
                        if let walletCD = walletCD {
                            newTransaction.wallet = walletCD
                        } else {
                            let newWallet = NSEntityDescription.insertNewObject(forEntityName: "WalletModel", into: context) as? WalletModel
                            newWallet?.address = self.address
                            newWallet?.isHD = self.isHD
                            newWallet?.data = self.data
                            newWallet?.name = self.name
                            newWallet?.isSelected = true
                        }
                    }
                }
                try context.save()
                group.leave()
            } catch let someErr {
                error = someErr
                group.leave()
            }
        }
        group.wait()
        if let resErr = error {
            throw resErr
        }
    }
    
    func getAllTransactions(for network: Web3Network) throws -> [ETHTransaction] {
        do {
            guard let result = try ContainerCD.context.fetch(self.fetchWalletRequest(with: self.address)).first else {
                throw Errors.WalletErrors.cantGetTx
            }
            guard var transactions = result.transactions?.allObjects as? [ETHTransactionModel] else {
                throw Errors.CommonErrors.wrongType
            }
            transactions = transactions.filter {
                $0.networkId == network.id
            }
            return transactions.map {
                return ETHTransaction(transactionHash: $0.transactionHash!,
                                      from: $0.from!,
                                      to: $0.to!,
                                      amount: $0.amount!,
                                      date: $0.date!,
                                      data: $0.data,
                                      token: $0.token.flatMap {
                                        return ERC20Token(name: $0.name!,
                                                          address: $0.address!,
                                                          decimals: $0.decimals!,
                                                          symbol: $0.symbol!)
                    }, networkId: $0.networkId,
                       isPending: $0.isPending)
            }
        } catch let error {
            throw error
        }
    }
    
    internal func buildTokenslist(from results: [[String: Any]]) throws -> [ERC20Token] {
        var tokens = [ERC20Token]()
        for result in results {
            guard let balance = result["balance"] as? String,
                let contractAddress = result["contractAddress"] as? String,
                let decimals = result["decimals"] as? String,
                let name = result["name"] as? String,
                let symbol = result["symbol"] as? String else {
                    throw Errors.NetworkErrors.wrongJSON
            }
            let token = ERC20Token(name: name, address: contractAddress, decimals: decimals, symbol: symbol)
            token.balance = balance
            tokens.append(token)
        }
        return tokens
    }
    
    internal func buildTXlist(from results: [[String: Any]],
                              txType: TransactionType,
                              networkId: Int64) throws -> [ETHTransaction] {
        var transactions = [ETHTransaction]()
        for result in results {
            guard let from = result["from"] as? String,
                let to = result["to"] as? String,
                let timestamp = Double((result["timeStamp"] as? String)!),
                let value = result["value"] as? String,
                let hash = result["hash"] as? String else {
                    throw Errors.NetworkErrors.wrongJSON
            }
            guard let data = result["input"] as? String else {
                throw Errors.NetworkErrors.wrongJSON
            }
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            var tokenModel: ERC20Token?
            if txType == .arbitraryMethodWithParams {
                guard let tokenName = result["tokenName"] as? String,
                    let tokenSymbol = result["tokenSymbol"] as? String,
                    let tokenDecimal = result["tokenDecimal"] as? String,
                    let tokenAddress = result["contractAddress"] as? String else {
                        throw Errors.NetworkErrors.wrongJSON
                }
                tokenModel = ERC20Token(name: tokenName,
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
            let transaction = ETHTransaction(transactionHash: hash,
                                             from: from,
                                             to: to,
                                             amount: amountString,
                                             date: date,
                                             data: Data.fromHex(data),
                                             token: tokenModel,
                                             networkId: networkId,
                                             isPending: false)
            transactions.append(transaction)
        }
        return transactions
    }
    
    public func loadTransactions(txType: TransactionType?,
                                 network: Web3Network) throws -> [ETHTransaction] {
        let type = txType ?? .arbitraryMethodWithParams
        return try self.loadTransactionsPromise(for: self.address, txType: type, networkId: network.id).wait()
    }
    
    private func loadTransactionsPromise(for address: String,
                                         txType: TransactionType,
                                         networkId: Int64) -> Promise<[ETHTransaction]> {
        let returnPromise = Promise<[ETHTransaction]> { (seal) in
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
    
    private func fetchTokenRequest(withAddress address: String) -> NSFetchRequest<ERC20TokenModel> {
        let fr: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
    
    private func fetchWalletRequest(with address: String) -> NSFetchRequest<WalletModel> {
        let fr: NSFetchRequest<WalletModel> = WalletModel.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
}
