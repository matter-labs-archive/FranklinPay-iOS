//
//  TokensStorage.swift
//  DiveLane
//
//  Created by Anton Grigorev on 27/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import CoreData

protocol ITokensStorage {
    func getAllTokens(for wallet: WalletModel, networkId: Int64) throws -> [ERC20TokenModel]
    func saveCustomToken(from dict: [String: Any]) throws
    func saveCustomToken(token: ERC20TokenModel, wallet: WalletModel, networkId: Int64) throws
    func getToken(token: ERC20TokenModel) throws -> ERC20TokenModel
    func getTokensList(for searchingString: String) throws -> [ERC20TokenModel]
    func deleteToken(token: ERC20TokenModel, wallet: WalletModel, networkId: Int64) throws
}

public class TokensStorage: ITokensStorage {
    
    public func saveCustomToken(from dict: [String: Any]) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.container.performBackgroundTask { (context) in
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
                if let entity = try ContainerCD.mainContext!.fetch(token).first {
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
        ContainerCD.container.performBackgroundTask { (context) in
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
            let results = try ContainerCD.mainContext!.fetch(requestTokens)
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
            let results = try ContainerCD.mainContext!.fetch(requestToken)
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
            let results = try ContainerCD.mainContext!.fetch(requestToken)
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
            let results = try ContainerCD.mainContext!.fetch(requestToken)
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
            ContainerCD.mainContext!.delete(token)
            try ContainerCD.mainContext!.save()
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
