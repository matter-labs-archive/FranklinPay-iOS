//
//  ERC20TokenStorage.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import CoreData

protocol IERC20TokenStorage {
    func saveIn(wallet: Wallet, network: Web3Network) throws
    func select(in wallet: Wallet, network: Web3Network) throws
    func saveBalance(in wallet: Wallet, network: Web3Network, balance: String) throws
    func saveRate(rate: Double, change24: Double) throws
}

extension ERC20Token: IERC20TokenStorage {
    
    public func saveIn(wallet: Wallet, network: Web3Network) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "ERC20TokenModel",
                                                                   into: context) as? ERC20TokenModel else {
                                                                    error = Errors.TokenErrors.cantCreateToken
                                                                    group.leave()
                                                                    return
            }
            entity.address = self.address
            entity.name = self.name
            entity.symbol = self.symbol
            entity.decimals = self.decimals
            entity.isAdded = true
            entity.walletAddress = wallet.address
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
    
    public func select(in wallet: Wallet, network: Web3Network) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "networkId == %@ && isAdded == %@ && walletAddress == %@",
                                             NSNumber(value: network.id),
                                             NSNumber(value: true),
                                             NSString(string: wallet.address)
        )
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            for item in results {
                let isEqual = item.address == self.address
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
    
    public func saveBalance(in wallet: Wallet, network: Web3Network, balance: String) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "networkId == %@ && isAdded == %@ && walletAddress == %@",
                                             NSNumber(value: network.id),
                                             NSNumber(value: true),
                                             NSString(string: wallet.address)
        )
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            for item in results where item.address == self.address {
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
    
    public func saveRate(rate: Double, change24: Double) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            for item in results where item.address == self.address {
                item.rate = rate
                item.change24 = change24
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
    
}
