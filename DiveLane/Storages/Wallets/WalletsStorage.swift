//
//  WalletsStorage.swift
//  DiveLane
//
//  Created by Anton Grigorev on 27/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import CoreData

protocol IWalletsStorage {
    func getSelectedWallet() throws -> WalletModel
    func saveWallet(wallet: WalletModel) throws
    func deleteWallet() throws
    func getAllWallets() throws -> [WalletModel]
    func deleteWallet(wallet: WalletModel) throws
    func selectWallet(wallet: WalletModel) throws
}

public class WalletsStorage {
    
    public func getSelectedWallet() throws -> WalletModel {
        let requestWallet: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "isSelected = %@", NSNumber(value: true))
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            guard let result = results.first else {
                throw Errors.StorageErrors.noSelectedWallet
            }
            return WalletModel.fromCoreData(crModel: result)
            
        } catch let error {
            throw error
        }
    }
    
    public func getAllWallets() throws -> [WalletModel] {
        let requestWallet: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            return results.map {
                return WalletModel.fromCoreData(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    public func saveWallet(wallet: WalletModel) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "Wallet", into: context) as? Wallet else {
                error = Errors.StorageErrors.cantCreateWallet
                group.leave()
                return
            }
            entity.address = wallet.address
            entity.data = wallet.data
            entity.name = wallet.name
            entity.isHD = wallet.isHD
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
    
    public func deleteWallet(wallet: WalletModel) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestWallet: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "address = %@", wallet.address)
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            guard let wallet = results.first else {
                error = Errors.StorageErrors.noSuchWalletInStorage
                group.leave()
                return
            }
            ContainerCD.context.delete(wallet)
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
    
    public func selectWallet(wallet: WalletModel) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestWallet: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            for item in results {
                let isEqual = item.address == wallet.address
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
    
    private func fetchWalletRequest(with address: String) -> NSFetchRequest<Wallet> {
        let fr: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
    
}
