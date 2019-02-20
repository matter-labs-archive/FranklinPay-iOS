//
//  WalletStorage.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import CoreData

protocol IWalletStorage {
    func select() throws
    func save() throws
    func delete() throws
    func performBackup() throws
}

extension Wallet: IWalletStorage {
    public func save() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "WalletModel", into: context) as? WalletModel else {
                error = Errors.WalletErrors.cantCreateWallet
                group.leave()
                return
            }
            entity.address = self.address
            entity.data = self.data
            entity.name = self.name
            entity.isHD = self.isHD
            entity.backup = self.backup
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
    
    public func select() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestWallet: NSFetchRequest<WalletModel> = WalletModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
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
    
    public func performBackup() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestWallet: NSFetchRequest<WalletModel> = WalletModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            for item in results where item.address == self.address {
                item.backup = nil
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
    
    public func delete() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestWallet: NSFetchRequest<WalletModel> = WalletModel.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "address = %@", self.address)
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            guard let wallet = results.first else {
                error = Errors.WalletErrors.wrongWallet
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
}
