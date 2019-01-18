//
//  TokensService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
import EthereumAddress
import Web3swift
private typealias PromiseResult = PromiseKit.Result
import CoreData

protocol ITokensStorage {
    func saveCustomToken(from dict: [String: Any]) throws
    func getToken(token: ERC20Token) throws -> ERC20Token
    func getTokensList(for searchingString: String) throws -> [ERC20Token]
}

protocol ITokensService {
    func getFullTokensList(for searchString: String) throws -> [ERC20Token]
    func downloadAllAvailableTokensIfNeeded() throws
}

public class TokensService: ITokensService {
    
    public func contract(for address: String) throws -> web3.web3contract {
        guard let ethAddress = EthereumAddress(address),
            let web3 = self.web3Instance,
            let contract = web3.contract(Web3.Utils.erc20ABI,
                                         at: ethAddress,
                                         abiVersion: 2) else {
                                            throw Web3Error.dataError
        }
        return contract
    }
    
    public var web3Instance: web3? {
        guard let web3 = CurrentNetwork.currentWeb,
            let wallet = CurrentWallet.currentWallet else {return nil}
        let keystoreManager = wallet.keystoreManager
        web3.addKeystoreManager(keystoreManager)
        return web3
    }
    
    public var currentAddress: EthereumAddress? {
        guard let wallet = CurrentWallet.currentWallet else {return nil}
        let address = wallet.address
        guard let ethAddressFrom = EthereumAddress(address) else {return nil}
        return ethAddressFrom
    }
    
    public func defaultOptions() -> TransactionOptions {
        var options = TransactionOptions.defaultOptions
        let address = self.currentAddress
        options.from = address
        return options
    }
    
    public func getFullTokensList(for searchString: String) throws -> [ERC20Token] {
        return try self.getFullTokensList(for: searchString).wait()
    }
    
    private func getFullTokensList(for searchString: String) -> Promise<[ERC20Token]> {
        let returnPromise = Promise<[ERC20Token]> { (seal) in
            var tokensList: [ERC20Token] = []
            do {
                let tokens = try self.getTokensList(for: searchString)
                if !tokens.isEmpty {
                    for token in tokens {
                        let tokenModel = ERC20Token(name: token.name,
                                                    address: token.address,
                                                    decimals: token.decimals,
                                                    symbol: token.symbol)
                        tokensList.append(tokenModel)
                    }
                    seal.fulfill(tokensList)
                } else {
                    let token = try self.getTokenFromNet(with: searchString)
                    seal.fulfill([token])
                }
            } catch let error {
                seal.reject(error)
            }
        }
        return returnPromise
    }

    private func name(for tokenAddress: String) throws -> String {
        do {
            let contract = try self.contract(for: tokenAddress)
            let options = self.defaultOptions()
            guard let transaction = contract.read("name", parameters: [AnyObject](), extraData: Data(), transactionOptions: options) else {
                throw Web3Error.transactionSerializationError
            }
            let result = try transaction.call(transactionOptions: options)
            guard let name = result["0"] as? String, !name.isEmpty else {
                throw Web3Error.dataError
            }
            return name
        } catch let error {
            throw error
        }
    }

    private func symbol(for tokenAddress: String) throws -> String {
        do {
            let contract = try self.contract(for: tokenAddress)
            let options = self.defaultOptions()
            guard let transaction = contract.read("symbol", parameters: [AnyObject](), extraData: Data(), transactionOptions: options) else {
                throw Web3Error.transactionSerializationError
            }
            let result = try transaction.call(transactionOptions: options)
            guard let symbol = result["0"] as? String, !symbol.isEmpty else {
                throw Web3Error.dataError
            }
            return symbol
        } catch let error {
            throw error
        }
    }

    private func decimals(for tokenAddress: String) throws -> BigUInt {
        do {
            let contract = try self.contract(for: tokenAddress)
            let options = self.defaultOptions()
            guard let transaction = contract.read("decimals", parameters: [AnyObject](), extraData: Data(), transactionOptions: options) else {
                throw Web3Error.transactionSerializationError
            }
            let result = try transaction.call(transactionOptions: options)
            guard let decimals = result["0"] as? BigUInt else {
                throw Web3Error.dataError
            }
            return decimals
        } catch let error {
            throw error
        }
    }

    private func getTokenFromNet(with address: String) throws -> ERC20Token {

        guard EthereumAddress(address) != nil else {
            throw Web3Error.inputError(desc: "Wrong address")
        }

        let name = try self.name(for: address)
        let decimals = try self.decimals(for: address)
        let symbol = try self.symbol(for: address)
        
        guard !name.isEmpty, !symbol.isEmpty else {
            throw Web3Error.dataError
        }
        return ERC20Token(name: name,
                               address: address,
                               decimals: decimals.description,
                               symbol: symbol)
    }
    
    public func downloadAllAvailableTokensIfNeeded() throws {
        let group = DispatchGroup()
        group.enter()
        var err: Error?
        guard let url = URL(string: URLs.downloadTokensList) else {
            err = Errors.NetworkErrors.wrongURL
            group.leave()
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data = data {
                do {
                    if let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        let dictsCount = jsonSerialized.count
                        var counter = 0
                        try jsonSerialized.forEach({ (dict) in
                            counter += 1
                            try self.saveCustomToken(from: dict)
                            if counter == dictsCount {
                                group.leave()
                            }
                        })
                    }
                } catch let someErr {
                    err = someErr
                    group.leave()
                }
            } else {
                err = Errors.NetworkErrors.noData
                group.leave()
            }
        }
        task.resume()
        group.wait()
        if let resErr = err {
            throw resErr
        }
    }
}

extension TokensService: ITokensStorage {
    
    public func getToken(token: ERC20Token) throws -> ERC20Token {
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format: "address = %@", token.address)
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            let mappedRes = try results.map {
                return try ERC20Token(crModel: $0)
                }.first
            guard let token = mappedRes else {
                throw Errors.StorageErrors.cantGetContact
            }
            return token
        } catch let error {
            throw error
        }
    }
    
    public func getTokensList(for searchingString: String) throws -> [ERC20Token] {
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "walletAddress = %@ && (address CONTAINS[c] %@ || name CONTAINS[c] %@ || symbol CONTAINS[c] %@)",
                                             "",
                                             searchingString,
                                             searchingString,
                                             searchingString)
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            return try results.map {
                return try ERC20Token(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    public func saveCustomToken(from dict: [String: Any]) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            do {
                let token: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
                guard let address = dict["address"] as? String else {
                    error = Errors.StorageErrors.cantCreateToken
                    group.leave()
                    return
                }
                token.predicate = NSPredicate(format: "address = %@", address)
                guard var newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20TokenModel", into: context) as? ERC20TokenModel else {
                    error = Errors.StorageErrors.cantCreateToken
                    group.leave()
                    return
                }
                if let entity = try ContainerCD.context.fetch(token).first {
                    newToken = entity
                }
                
                newToken.address = dict["address"] as? String
                newToken.symbol = dict["symbol"] as? String
                newToken.name = newToken.symbol
                newToken.decimals = String((dict["decimal"] as? Int) ?? 0)
                newToken.networkId = 0
                newToken.isAdded = false
                newToken.walletAddress = ""
                
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
    
    private func fetchTokenRequest(withAddress address: String) -> NSFetchRequest<ERC20TokenModel> {
        let fr: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
}
