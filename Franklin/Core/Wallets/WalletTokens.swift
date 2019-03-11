//
//  WalletTokens.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import CoreData

protocol IWalletTokensStorage {
    func select(token: ERC20Token, network: Web3Network) throws
    func setBalance(token: ERC20Token, network: Web3Network, balance: String) throws
    func setUsdBalance(token: ERC20Token, network: Web3Network, usdBalance: String) throws
    func add(token: ERC20Token, network: Web3Network) throws
    func delete(token: ERC20Token, network: Web3Network) throws
    func getAllTokens(network: Web3Network) throws -> [ERC20Token]
    func getSelectedToken(network: Web3Network) throws -> ERC20Token
    func isTokenExists(token: ERC20Token, network: Web3Network) throws -> Bool
}

extension Wallet: IWalletTokensStorage {
    
    func getSelectedToken(network: Web3Network) throws -> ERC20Token {
        do {
            let requestTokens: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
            requestTokens.predicate = NSPredicate(format:
                "networkId == %@ && isAdded == %@ && isSelected == %@ && walletAddress == %@",
                                                  NSNumber(value: network.id),
                                                  NSNumber(value: true),
                                                  NSNumber(value: true),
                                                  NSString(string: self.address)
            )
            let results = try ContainerCD.context.fetch(requestTokens)
            guard let result = results.first else {
                throw Errors.WalletErrors.noSelectedToken
            }
            return try ERC20Token(crModel: result)
        } catch let error {
            throw error
        }
    }
    
    public func select(token: ERC20Token, network: Web3Network) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "networkId == %@ && isAdded == %@ && walletAddress == %@",
                                             NSNumber(value: network.id),
                                             NSNumber(value: true),
                                             NSString(string: self.address)
        )
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            for item in results {
                let isEqual = item.address == token.address
                item.isSelected = isEqual
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
    
    public func setBalance(token: ERC20Token, network: Web3Network, balance: String) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "networkId == %@ && isAdded == %@ && walletAddress == %@",
                                             NSNumber(value: network.id),
                                             NSNumber(value: true),
                                             NSString(string: self.address),
                                             NSString(string: token.address)
        )
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            for item in results where item.address == token.address {
                item.balance = balance
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
    
    public func setUsdBalance(token: ERC20Token, network: Web3Network, usdBalance: String) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "networkId == %@ && isAdded == %@ && walletAddress == %@",
                                             NSNumber(value: network.id),
                                             NSNumber(value: true),
                                             NSString(string: self.address),
                                             NSString(string: token.address)
        )
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            for item in results where item.address == token.address {
                item.usdBalance = usdBalance
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
    
    public func add(token: ERC20Token, network: Web3Network) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "ERC20TokenModel",
                                                                   into: context) as? ERC20TokenModel else {
                                                                    error = Errors.WalletErrors.cantAddToken
                                                                    group.leave()
                                                                    return
            }
            entity.address = token.address
            entity.name = token.name
            entity.symbol = token.symbol
            entity.decimals = token.decimals
            entity.isAdded = true
            entity.walletAddress = self.address
            entity.networkId = network.id
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
    
    public func delete(token: ERC20Token, network: Web3Network) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "networkId == %@ && isAdded == %@ && walletAddress == %@ && address == %@",
                                             NSNumber(value: network.id),
                                             NSNumber(value: true),
                                             NSString(string: self.address),
                                             NSString(string: token.address)
        )
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            guard let result = results.first else {
                error = Errors.WalletErrors.cantDeleteToken
                group.leave()
                return
            }
            ContainerCD.context.delete(result)
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
    
    public func getAllTokens(network: Web3Network) throws -> [ERC20Token] {
        do {
            let requestTokens: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
            requestTokens.predicate = NSPredicate(format:
                "networkId == %@ && isAdded == %@ && walletAddress == %@",
                                                  NSNumber(value: network.id),
                                                  NSNumber(value: true),
                                                  NSString(string: self.address)
            )
            let results = try ContainerCD.context.fetch(requestTokens)
            return try results.map {
                return try ERC20Token(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    public func isTokenExists(token: ERC20Token, network: Web3Network) throws -> Bool {
        do {
            let tokens = try self.getAllTokens(network: network)
            for tok in tokens {
                if tok.address == token.address {
                    return true
                }
            }
            return false
        } catch let error {
            throw error
        }
    }
}
