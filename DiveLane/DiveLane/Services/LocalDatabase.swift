//
//  LocalDatabase.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import CoreData
import struct BigInt.BigUInt

protocol ILocalDatabase {
    func getWallet() -> KeyWalletModel?
    func saveWallet(wallet: KeyWalletModel?, completion: @escaping (Error?)-> Void)
    func deleteWallet(completion: @escaping (Error?)-> Void)
    func getAllWallets() -> [KeyWalletModel]
    func selectWallet(wallet: KeyWalletModel?, completion: @escaping() -> Void)
}

class LocalDatabase: ILocalDatabase {
    
    lazy var container: NSPersistentContainer = NSPersistentContainer(name: "CoreDataModel")
    private lazy var mainContext = self.container.viewContext
    
    init() {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }
    
    public func getWallet() -> KeyWalletModel? {
        let requestWallet: NSFetchRequest<KeyWallet> = KeyWallet.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "isSelected = %@", NSNumber(value: true))
        do {
            let results = try mainContext.fetch(requestWallet)
            guard let result = results.first else { return nil }
            return KeyWalletModel.fromCoreData(crModel: result)
            
        } catch {
            print(error)
            return nil
        }
        
    }
    
    public func getAllWallets() -> [KeyWalletModel] {
        let requestWallet: NSFetchRequest<KeyWallet> = KeyWallet.fetchRequest()
        do {
            let results = try mainContext.fetch(requestWallet)
            return results.map{ return KeyWalletModel.fromCoreData(crModel: $0)}
            
        } catch {
            print(error)
            return []
        }
    }
    
    public func saveWallet(wallet: KeyWalletModel?, completion: @escaping (Error?)-> Void) {
        container.performBackgroundTask { (context) in
            guard let wallet = wallet else { return }
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "KeyWallet", into: context) as? KeyWallet else { return }
            entity.address = wallet.address
            entity.data = wallet.data
            entity.name = wallet.name
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.selectWallet(wallet: wallet, completion: {
                        completion(nil)
                    })
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.selectWallet(wallet: wallet, completion: {
                        completion(error)
                    })
                }
            }
        }
    }
    
    public func deleteWallet(completion: @escaping (Error?)-> Void) {
        
        let requestWallet: NSFetchRequest<KeyWallet> = KeyWallet.fetchRequest()
        do {
            let results = try mainContext.fetch(requestWallet)
            
            for item in results {
                mainContext.delete(item)
            }
            try mainContext.save()
            completion(nil)
            
        } catch {
            completion(error)
        }
    }
    
    public func selectWallet(wallet: KeyWalletModel?, completion: @escaping() -> Void) {
        let requestWallet: NSFetchRequest<KeyWallet> = KeyWallet.fetchRequest()
        do {
            let results = try mainContext.fetch(requestWallet)
            for item in results {
                item.isSelected = item.address == wallet?.address
            }
            try mainContext.save()
            completion()
        } catch {
            completion()
        }
    }
}
