//
//  WalletPlasma.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import CoreData
import Web3swift
import BigInt
import EthereumAddress
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IWalletPlasma {
    func getID() throws -> BigUInt
    func setID(_ id: String) throws
    func getIgnisBalance(network: Web3Network) throws -> String
    func getIgnisNonce(network: Web3Network) throws -> BigUInt
    func sendPlasmaTx(nonce: BigUInt, to: EthereumAddress, value: String, network: Web3Network) throws -> Bool
    //func loadTransactions(network: Web3Network) throws -> [ETHTransaction]
}

extension Wallet: IWalletPlasma {
    
    public func getID() throws -> BigUInt {
        let plasmaService = PlasmaService()
        do {
            let id = try plasmaService.getID(for: EthereumAddress(self.address)!)
            return id
        } catch let error {
            throw error
        }
    }
    
    public func setID(_ id: String) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestWallet: NSFetchRequest<WalletModel> = WalletModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            for item in results where item.address == self.address {
                item.plasmaID = id
                self.plasmaID = id
            }
            try ContainerCD.context.save()
            group.leave()
        } catch let someErr {
            error = someErr
            group.leave()
        }
        group.wait()
        if let resErr = error {
            throw resErr
        }
    }
    
    public func getIgnisBalance(network: Web3Network) throws -> String {
        if network.id != 1 && network.id != 4 {
            throw Errors.NetworkErrors.wrongURL
        }
        let onTestnet = network.id == 4 ? true : false
        return try self.getIgnisBalancePromise(onTestnet: onTestnet).wait()
    }
    
    private func getIgnisBalancePromise(onTestnet: Bool) -> Promise<String> {
        let returnPromise = Promise<String> { (seal) in
            guard let id = self.plasmaID else {
                seal.reject(Errors.NetworkErrors.noData)
                return
            }
            guard let url = URL(string: (onTestnet ? PlasmaURLs.getDataTestnet : PlasmaURLs.getDataMainnet) + id) else {
                seal.reject(Errors.NetworkErrors.wrongURL)
                return
            }
            guard let request = request(url: url,
                                        data: nil,
                                        method: .get,
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
                    guard let verified = json["verified"] as? [String: Any] else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    guard let balance = verified["balance"] as? String else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    guard let floatBalance = Float(balance) else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    let trueBalance = String(floatBalance/1000000)
                    seal.fulfill(trueBalance)
                } catch let err {
                    seal.reject(err)
                }
            }).resume()
        }
        return returnPromise
    }
    
    public func getIgnisNonce(network: Web3Network) throws -> BigUInt {
        if network.id != 1 && network.id != 4 {
            throw Errors.NetworkErrors.wrongURL
        }
        let onTestnet = network.id == 4 ? true : false
        return try self.getIgnisNoncePromise(onTestnet: onTestnet).wait()
    }
    
    private func getIgnisNoncePromise(onTestnet: Bool) -> Promise<BigUInt> {
        let returnPromise = Promise<BigUInt> { (seal) in
            guard let id = self.plasmaID else {
                seal.reject(Errors.NetworkErrors.noData)
                return
            }
            guard let url = URL(string: (onTestnet ? PlasmaURLs.getDataTestnet : PlasmaURLs.getDataMainnet) + id) else {
                seal.reject(Errors.NetworkErrors.wrongURL)
                return
            }
            guard let request = request(url: url,
                                        data: nil,
                                        method: .get,
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
                    guard let verified = json["verified"] as? [String: Any] else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    guard let nonce = verified["nonce"] as? UInt else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    let bnNonce = BigUInt(nonce)
                    seal.fulfill(bnNonce)
                } catch let err {
                    seal.reject(err)
                }
            }).resume()
        }
        return returnPromise
    }
    
    public func sendPlasmaTx(nonce: BigUInt, to: EthereumAddress, value: String, network: Web3Network) throws -> Bool {
        if network.id != 1 && network.id != 4 {
            throw Errors.NetworkErrors.wrongURL
        }
        let onTestnet = network.id == 4 ? true : false
        guard let fromid = self.plasmaID else {
            throw Errors.WalletErrors.noPlasmaID
        }
        guard let fromID = BigUInt(fromid) else {
            throw Errors.CommonErrors.wrongType
        }
        let toID = try PlasmaService().getID(for: to)
        let nonce = try self.getIgnisNonce(network: network)
        guard let amount = BigUInt(value) else {
            throw Errors.CommonErrors.wrongType
        }
        let trueAmount = amount * 1000000
        let tx = PlasmaTransaction()
        do {
            let pv = try self.getPassword()
            let pk = try self.getPrivateKey(withPassword: pv)
            let transaction = try tx.createTransaction(from: fromID, to: toID, amount: trueAmount, nonce: nonce, privateKey: pk)
            
            return try self.sendPlasmaTxPromise(transaction: transaction, onTestnet: onTestnet).wait()
        } catch let error {
            throw error
        }
    }
    
    private func sendPlasmaTxPromise(transaction: [AnyHashable : Any], onTestnet: Bool) -> Promise<Bool> {
        
        let returnPromise = Promise<Bool> { (seal) in
            guard let theJSONData = try? JSONSerialization.data(withJSONObject: transaction,
                                                                options: [.prettyPrinted]) else {
                                                                    seal.reject(Errors.NetworkErrors.wrongJSON)
                                                                    return
            }
            let url = onTestnet ? PlasmaURLs.sendRawTXTestnet : PlasmaURLs.sendRawTXMainnet
            guard let request = request(url: url,
                                        data: theJSONData,
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
                    guard let accepted = json["accepted"] as? Bool else {
                        seal.reject(Errors.NetworkErrors.wrongJSON)
                        return
                    }
                    seal.fulfill(accepted)
                } catch let err {
                    seal.reject(err)
                }
            }).resume()
        }
        return returnPromise
    }
    
    //    public func loadTransactions(network: Web3Network) throws -> [ETHTransaction] {
    //        if network.id != 1 && network.id != 4 {
    //            throw Errors.NetworkErrors.wrongURL
    //        }
    //        let onTestnet = network.id == 4 ? true : false
    //        return try self.loadTransactionsPromise(onTestnet: onTestnet).wait()
    //    }
    //
    //    private func loadTransactionsPromise(onTestnet: Bool) -> Promise<[ETHTransaction]> {
    //        let returnPromise = Promise<[ETHTransaction]> { (seal) in
    //            guard let id = self.plasmaID else {
    //                seal.reject(Errors.NetworkErrors.noData)
    //                return
    //            }
    //            let url = onTestnet ? IgnisURLs.getTXsTestnet : IgnisURLs.getTXsMainnet
    //            let json: [String: Any] = ["address": id]
    //            let jsonData = try? JSONSerialization.data(withJSONObject: json)
    //            guard let request = request(url: url,
    //                                        data: jsonData,
    //                                        method: .get,
    //                                        contentType: .json) else {
    //                                            seal.reject(PlasmaErrors.NetErrors.cantCreateRequest)
    //                                            return
    //            }
    //            session.dataTask(with: request, completionHandler: { (data, response, error) in
    //                if let error = error {
    //                    seal.reject(error)
    //                }
    //                guard let data = data else {
    //                    seal.reject(Errors.NetworkErrors.noData)
    //                    return
    //                }
    //                do {
    //                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
    //                        seal.reject(Errors.NetworkErrors.wrongJSON)
    //                        return
    //                    }
    //                    guard let results = json["result"] as? [[String: Any]] else {
    //                        seal.reject(Errors.NetworkErrors.wrongJSON)
    //                        return
    //                    }
    //                    do {
    //                        let transaction = try self.buildTXlist(from: results,
    //                                                               txType: .custom,
    //                                                               networkId: onTestnet ? 4 : 1)
    //                        seal.fulfill(transaction)
    //                    } catch let err {
    //                        seal.reject(err)
    //                    }
    //                } catch let err {
    //                    seal.reject(err)
    //                }
    //            }).resume()
    //        }
    //        return returnPromise
    //    }
}
