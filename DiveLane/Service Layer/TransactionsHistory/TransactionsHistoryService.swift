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
import CoreData
private typealias PromiseResult = PromiseKit.Result

protocol ITransactionsHistoryService {
    func loadTransactions(for address: String,
                          txType: TransactionType?,
                          networkId: Int64) throws -> [ETHTransactionModel]
    func saveTransactions(transactions: [ETHTransactionModel], for wallet: WalletModel) throws
    func getAllTransactions(for wallet: WalletModel, networkId: Int64) throws -> [ETHTransactionModel]
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
    
    public func saveTransactions(transactions: [ETHTransactionModel], for wallet: WalletModel) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            do {
                for transaction in transactions {
                    let fr: NSFetchRequest<ETHTransaction> = ETHTransaction.fetchRequest()
                    fr.predicate = NSPredicate(format: "transactionHash = %@", transaction.transactionHash)
                    let result = try context.fetch(fr).first
                    if let result = result {
                        result.amount = transaction.amount
                        result.data = transaction.data
                        result.date = transaction.date
                        result.from = transaction.from
                        result.networkID = transaction.networkID
                        result.to = transaction.to
                        result.isPending = false
                        //Update information stored in local storage.
                    } else {
                        guard let newTransaction = NSEntityDescription.insertNewObject(forEntityName: "ETHTransaction", into: context) as? ETHTransaction else {
                            error = Errors.StorageErrors.cantCreateTransaction
                            group.leave()
                            return
                        }
                        newTransaction.amount = transaction.amount
                        newTransaction.data = transaction.data
                        newTransaction.date = transaction.date
                        newTransaction.from = transaction.from
                        newTransaction.networkID = transaction.networkID
                        newTransaction.to = transaction.to
                        newTransaction.isPending = false
                        
                        if let contractAddress = transaction.token?.address {
                            //In case of ERC20 tokens
                            let result = try context.fetch(self.fetchTokenRequest(withAddress: contractAddress)).first
                            if let token = result {
                                newTransaction.token = token
                            } else {
                                let newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20Token", into: context) as? ERC20Token
                                newToken?.address = transaction.token?.address
                                newToken?.decimals = transaction.token?.decimals
                                newToken?.name = transaction.token?.name
                                newToken?.symbol = transaction.token?.symbol
                                newToken?.networkID = transaction.networkID
                                newTransaction.token = newToken
                            }
                        } else {
                            //In case of custom ETH transaction
                            let result = try context.fetch(self.fetchTokenRequest(withAddress: ""))
                            if let ethToken = result.first {
                                newTransaction.token = ethToken
                            } else {
                                let newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20Token", into: context) as? ERC20Token
                                newToken?.address = ""
                                newToken?.name = "Ether"
                                newToken?.decimals = "18"
                                newToken?.symbol = "ETH"
                                newTransaction.token = newToken
                            }
                            
                        }
                        newTransaction.transactionHash = transaction.transactionHash
                        // MARK: - Fetch wallet from core data, and if there is no one wallet - create.
                        let walletCD = try context.fetch(self.fetchWalletRequest(with: wallet.address)).first
                        if let walletCD = walletCD {
                            newTransaction.wallet = walletCD
                        } else {
                            let newWallet = NSEntityDescription.insertNewObject(forEntityName: "KeyWallet", into: context) as? Wallet
                            newWallet?.address = wallet.address
                            newWallet?.isHD = wallet.isHD
                            newWallet?.data = wallet.data
                            newWallet?.name = wallet.name
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
    
    public func getAllTransactions(for wallet: WalletModel, networkId: Int64) throws -> [ETHTransactionModel] {
        do {
            guard let result = try ContainerCD.context.fetch(self.fetchWalletRequest(with: wallet.address)).first else {
                throw Errors.StorageErrors.cantGetTransaction
            }
            guard var transactions = result.transactions?.allObjects as? [ETHTransaction] else {
                throw Errors.StorageErrors.cantGetTransaction
            }
            transactions = transactions.filter {
                $0.networkID == networkId
            }
            return transactions.map {
                return ETHTransactionModel(transactionHash: $0.transactionHash!, from: $0.from!, to: $0.to!, amount: $0.amount!, date: $0.date!, data: $0.data, token: $0.token.flatMap {
                    return ERC20TokenModel(name: $0.name!, address: $0.address!, decimals: $0.decimals!, symbol: $0.symbol!)
                }, networkID: $0.networkID, isPending: $0.isPending)
            }
        } catch let error {
            throw error
        }
    }
    
    private func fetchTokenRequest(withAddress address: String) -> NSFetchRequest<ERC20Token> {
        let fr: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
    
    private func fetchWalletRequest(with address: String) -> NSFetchRequest<Wallet> {
        let fr: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
}
