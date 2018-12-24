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
import CoreData
import Web3swift
private typealias PromiseResult = PromiseKit.Result

protocol ITokensService {
    func getFullTokensList(for searchString: String) throws -> [ERC20TokenModel]
    func downloadAllAvailableTokensIfNeeded() throws
    func updateConversion(for token: ERC20TokenModel) throws -> Double
    
    func getAllTokens(for wallet: WalletModel, networkId: Int64) throws -> [ERC20TokenModel]
    func saveCustomToken(from dict: [String: Any]) throws
    func saveCustomToken(token: ERC20TokenModel, wallet: WalletModel, networkId: Int64) throws
    func getToken(token: ERC20TokenModel) throws -> ERC20TokenModel
    func getTokensList(for searchingString: String) throws -> [ERC20TokenModel]
    func deleteToken(token: ERC20TokenModel, wallet: WalletModel, networkId: Int64) throws
}

public class TokensService {

    let web3service = Web3Service()
    let ratesService = RatesService.service
    
    public func getFullTokensList(for searchString: String) throws -> [ERC20TokenModel] {
        return try self.getFullTokensList(for: searchString).wait()
    }
    
    private func getFullTokensList(for searchString: String) -> Promise<[ERC20TokenModel]> {
        let returnPromise = Promise<[ERC20TokenModel]> { (seal) in
            var tokensList: [ERC20TokenModel] = []
            do {
                let tokens = try self.getTokensList(for: searchString)
                if !tokens.isEmpty {
                    for token in tokens {
                        let tokenModel = ERC20TokenModel(name: token.name,
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
            let contract = try web3service.contract(for: tokenAddress)
            let options = web3service.defaultOptions()
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
            let contract = try web3service.contract(for: tokenAddress)
            let options = web3service.defaultOptions()
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
            let contract = try web3service.contract(for: tokenAddress)
            let options = web3service.defaultOptions()
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

    private func getTokenFromNet(with address: String) throws -> ERC20TokenModel {

        guard EthereumAddress(address) != nil else {
            throw Web3Error.inputError(desc: "Wrong address")
        }

        let name = try self.name(for: address)
        let decimals = try self.decimals(for: address)
        let symbol = try self.symbol(for: address)
        
        guard !name.isEmpty, !symbol.isEmpty else {
            throw Web3Error.dataError
        }
        return ERC20TokenModel(name: name,
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

    public func updateConversion(for token: ERC20TokenModel) throws -> Double {
        return try self.ratesService.updateConversionRate(for: token.symbol.uppercased())
    }
    
    public func saveCustomToken(from dict: [String: Any]) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            do {
                let token: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
                guard let address = dict["address"] as? String else {
                    error = Errors.StorageErrors.cantCreateToken
                    group.leave()
                    return
                }
                token.predicate = NSPredicate(format: "address = %@", address)
                guard var newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20Token", into: context) as? ERC20Token else {
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
                newToken.networkID = 0
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
    
    public func saveCustomToken(token: ERC20TokenModel,
                                wallet: WalletModel,
                                networkId: Int64) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "ERC20Token",
                                                                   into: context) as? ERC20Token else {
                                                                    error = Errors.StorageErrors.cantCreateToken
                                                                    group.leave()
                                                                    return
            }
            entity.address = token.address
            entity.name = token.name
            entity.symbol = token.symbol
            entity.decimals = token.decimals
            entity.isAdded = true
            entity.walletAddress = wallet.address
            entity.networkID = networkId
            do {
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
    
    public func getAllTokens(for wallet: WalletModel, networkId: Int64) throws -> [ERC20TokenModel] {
        do {
            let requestTokens: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
            requestTokens.predicate = NSPredicate(format:
                "networkID == %@ && isAdded == %@",
                                                  NSNumber(value: networkId),
                                                  NSNumber(value: true)
            )
            let results = try ContainerCD.context.fetch(requestTokens)
            let tokens = results.filter {
                $0.walletAddress == wallet.address
            }
            return tokens.map {
                return ERC20TokenModel.fromCoreData(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    public func getToken(token: ERC20TokenModel) throws -> ERC20TokenModel {
        let requestToken: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
        requestToken.predicate = NSPredicate(format: "address = %@", token.address)
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            let mappedRes = results.map {
                return ERC20TokenModel.fromCoreData(crModel: $0)
                }.first
            guard let token = mappedRes else {
                throw Errors.StorageErrors.cantGetContact
            }
            return token
        } catch let error {
            throw error
        }
    }
    
    public func getTokensList(for searchingString: String) throws -> [ERC20TokenModel] {
        let requestToken: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "walletAddress = %@ && (address CONTAINS[c] %@ || name CONTAINS[c] %@ || symbol CONTAINS[c] %@)",
                                             "",
                                             searchingString,
                                             searchingString,
                                             searchingString)
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            return results.map {
                return ERC20TokenModel.fromCoreData(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    public func deleteToken(token: ERC20TokenModel,
                            wallet: WalletModel,
                            networkId: Int64) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
        requestToken.predicate = NSPredicate(format: "walletAddress = %@", wallet.address)
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            let tokens = results.filter {
                $0.address == token.address
            }
            let tokensInNetwork = tokens.filter {
                $0.networkID == networkId
            }
            guard let token = tokensInNetwork.first else {
                error = Errors.StorageErrors.noSuchTokenInStorage
                group.leave()
                return
            }
            ContainerCD.context.delete(token)
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
    
    private func fetchTokenRequest(withAddress address: String) -> NSFetchRequest<ERC20Token> {
        let fr: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
}
