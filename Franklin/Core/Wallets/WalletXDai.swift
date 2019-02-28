//
//  WalletXDai.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import PromiseKit
private typealias PromiseResult = PromiseKit.Result
import BigInt
import EthereumAddress

protocol IWalletXDAI {
    func getXDAIBalance() throws -> String
    func getXDAITransactions() throws -> [ETHTransaction]
    func getXDAITokens() throws -> [ERC20Token]
    func prepareSendXDaiTx(web3instance: web3?,
                           toAddress: String,
                           value: String,
                           gasLimit: TransactionOptions.GasLimitPolicy,
                           gasPrice: TransactionOptions.GasPricePolicy) throws -> WriteTransaction
    func prepareSendERC20XDaiTx(web3instance: web3?,
                                token: ERC20Token,
                                toAddress: String,
                                tokenAmount: String,
                                gasLimit: TransactionOptions.GasLimitPolicy,
                                gasPrice: TransactionOptions.GasPricePolicy) throws -> WriteTransaction
}

extension Wallet: IWalletXDAI {
    public func getXDAIBalance() throws -> String {
        if let balance = try BigUInt(self.getXDAIBalancePromise().wait()) {
            return balance.getConvinientRepresentationBalance
        } else {
            throw Errors.NetworkErrors.noData
        }
    }
    
    private func getXDAIBalancePromise() -> Promise<String> {
        let returnPromise = Promise<String> { (seal) in
            guard let url = try? XDaiURLs().balance(address: self.address) else {
                seal.reject(Errors.NetworkErrors.wrongURL)
                return
            }
            //            let balanceJSON = BalanceXDAI(["params": [self.address,"latest"]])
            //            let jsonEncoder = JSONEncoder()
            //            let jsonData = try jsonEncoder.encode(balanceJSON)
            //            print(jsonData)
            //            let jsonString = String(data: jsonData, encoding: .utf8)
            //            print(jsonString)
            guard let request = request(url: url,
                                        data: nil,
                                        method: .post,
                                        contentType: .json) else {
                                            seal.reject(Errors.NetworkErrors.cantCreateRequest)
                                            return
            }
            session.dataTask(with: request, completionHandler: { (data, response, error) in
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
                    print(json)
                    guard let balance = json["result"] as? String else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    seal.fulfill(balance)
                } catch let err {
                    seal.reject(err)
                }
            }).resume()
        }
        return returnPromise
    }
    
    public func getXDAITransactions() throws -> [ETHTransaction] {
        return try self.getXDAITransactionsPromise().wait()
    }
    
    private func getXDAITransactionsPromise() -> Promise<[ETHTransaction]> {
        let returnPromise = Promise<[ETHTransaction]> { (seal) in
            guard let url = try? XDaiURLs().transactions(address: self.address) else {
                seal.reject(Errors.NetworkErrors.wrongURL)
                return
            }
            //            let balanceJSON = BalanceXDAI(["params": [self.address,"latest"]])
            //            let jsonEncoder = JSONEncoder()
            //            let jsonData = try jsonEncoder.encode(balanceJSON)
            //            print(jsonData)
            //            let jsonString = String(data: jsonData, encoding: .utf8)
            //            print(jsonString)
            guard let request = request(url: url,
                                        data: nil,
                                        method: .post,
                                        contentType: .json) else {
                                            seal.reject(Errors.NetworkErrors.cantCreateRequest)
                                            return
            }
            session.dataTask(with: request, completionHandler: { (data, response, error) in
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
                    print(json)
                    guard let results = json["result"] as? [[String: Any]] else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    do {
                        let transaction = try self.buildTXlist(from: results,
                                                               txType: .ether,
                                                               networkId: 100)
                        seal.fulfill(transaction)
                    } catch let err {
                        seal.reject(err)
                    }
                } catch let err {
                    seal.reject(err)
                }
            }).resume()
        }
        return returnPromise
    }
    
    public func getXDAITokens() throws -> [ERC20Token] {
        return try self.getXDAITokensPromise().wait()
    }
    
    private func getXDAITokensPromise() -> Promise<[ERC20Token]> {
        let returnPromise = Promise<[ERC20Token]> { (seal) in
            guard let url = try? XDaiURLs().tokens(address: self.address) else {
                seal.reject(Errors.NetworkErrors.wrongURL)
                return
            }
            //            let balanceJSON = BalanceXDAI(["params": [self.address,"latest"]])
            //            let jsonEncoder = JSONEncoder()
            //            let jsonData = try jsonEncoder.encode(balanceJSON)
            //            print(jsonData)
            //            let jsonString = String(data: jsonData, encoding: .utf8)
            //            print(jsonString)
            guard let request = request(url: url,
                                        data: nil,
                                        method: .post,
                                        contentType: .json) else {
                                            seal.reject(Errors.NetworkErrors.cantCreateRequest)
                                            return
            }
            session.dataTask(with: request, completionHandler: { (data, response, error) in
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
                    print(json)
                    guard let results = json["result"] as? [[String: Any]] else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    do {
                        let tokens = try self.buildTokenslist(from: results)
                        seal.fulfill(tokens)
                    } catch let err {
                        seal.reject(err)
                    }
                } catch let err {
                    seal.reject(err)
                }
            }).resume()
        }
        return returnPromise
    }
    
    public func prepareSendXDaiTx(web3instance: web3? = nil,
                                  toAddress: String,
                                  value: String = "0.0",
                                  gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                  gasPrice: TransactionOptions.GasPricePolicy = .automatic) throws -> WriteTransaction {
        guard let web3 = web3instance ?? self.web3Instance else {
            throw Web3Error.walletError
        }
        if web3instance != nil {
            web3.addKeystoreManager(self.keystoreManager)
        }
        guard let ethAddress = EthereumAddress(toAddress),
            let contract = web3.contract(ABIs.xdai, at: ethAddress, abiVersion: 2) else {
                throw Web3Error.dataError
        }
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = self.defaultOptions()
        options.value = amount
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        guard let tx = contract.write("fallback",
                                      parameters: [AnyObject](),
                                      extraData: Data(),
                                      transactionOptions: options) else {
                                        throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func prepareSendERC20XDaiTx(web3instance: web3? = nil,
                                       token: ERC20Token,
                                       toAddress: String,
                                       tokenAmount: String = "0.0",
                                       gasLimit: TransactionOptions.GasLimitPolicy,
                                       gasPrice: TransactionOptions.GasPricePolicy) throws -> WriteTransaction {
        guard let web3 = web3instance ?? self.web3Instance else {
            throw Web3Error.walletError
        }
        if web3instance != nil {
            web3.addKeystoreManager(self.keystoreManager)
        }
        guard let ethTokenAddress = EthereumAddress(token.address),
            let ethToAddress = EthereumAddress(toAddress),
            let contract = web3.contract(ABIs.xdaiERC20, at: ethTokenAddress, abiVersion: 2) else {
                throw Web3Error.dataError
        }
        let amount = Web3.Utils.parseToBigUInt(tokenAmount, units: .eth)
        var options = self.defaultOptions()
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        guard let tx = contract.write("transfer",
                                      parameters: [ethToAddress, amount] as [AnyObject],
                                      extraData: Data(),
                                      transactionOptions: options) else {
                                        throw Web3Error.transactionSerializationError
        }
        return tx
    }
}
