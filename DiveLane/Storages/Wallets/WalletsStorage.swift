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

class WalletsStorage {
    lazy var container: NSPersistentContainer = NSPersistentContainer(name: "CoreDataModel")
    private lazy var mainContext = self.container.viewContext
    
    init() {
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }
    
    public func getSelectedWallet() throws -> WalletModel {
        let requestWallet: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "isSelected = %@", NSNumber(value: true))
        do {
            let results = try mainContext.fetch(requestWallet)
            guard let result = results.first else {
                throw StorageErrors.noSelectedWallet
            }
            return WalletModel.fromCoreData(crModel: result)
            
        } catch let error {
            throw error
        }
    }
    
    public func getAllWallets() throws -> [WalletModel] {
        let requestWallet: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        do {
            let results = try mainContext.fetch(requestWallet)
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
        container.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "Wallet", into: context) as? Wallet else {
                error = StorageErrors.cantCreateWallet
                group.leave()
            }
            entity.address = wallet.address
            entity.data = wallet.data
            entity.name = wallet.name
            entity.isHD = wallet.isHD
            do {
                try context.save()
                group.leave()
            } catch let someErr{
                error = someErr
                group.leave()
            }
        }
        group.wait()
        if let resErr = error {
            throw resErr
        }
    }
    
    public func deleteWalletPromise(wallet: WalletModel) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestWallet: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "address = %@", wallet.address)
        do {
            let results = try mainContext.fetch(requestWallet)
            guard let wallet = results.first else {
                error = StorageErrors.noSuchWalletInStorage
                group.leave()
            }
            mainContext.delete(wallet)
            try mainContext.save()
            group.leave()
        } catch let someErr{
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
            let results = try mainContext.fetch(requestWallet)
            for item in results {
                let isEqual = item.address == wallet.address
                item.isSelected = isEqual
            }
            try mainContext.save()
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
    
    public func fetchWalletRequest(with address: String) -> NSFetchRequest<Wallet> {
        let fr: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
    
}
