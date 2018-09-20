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
    func deleteWallet(wallet: KeyWalletModel, completion: @escaping (Error?) -> Void)
    //func addToken(with token: ERC20TokenModel?, forWallet: KeyWalletModel, completion: @escaping (Error?) -> Void)
    func getAllTokens(for wallet: KeyWalletModel, forNetwork: Int64) -> [ERC20TokenModel]
    func saveCustomToken(with token: ERC20TokenModel?, forWallet: KeyWalletModel, forNetwork: Int64, completion: @escaping(Error?) -> Void)
    func getToken(token: ERC20TokenModel?) -> ERC20TokenModel?
    func getTokensList(for searchingString: String) -> [ERC20TokenModel]?
    func saveTransactions(transactions: [ETHTransactionModel], forWallet wallet: KeyWalletModel, completion: @escaping(Error?) -> Void)
    func getAllTransactions(forWallet wallet: KeyWalletModel, andNetwork networkID: Int64) -> [ETHTransactionModel]
    func deleteToken(token: ERC20TokenModel, forWallet: KeyWalletModel, forNetwork: Int64, completion: @escaping (Error?) -> Void)
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
            entity.isHD = wallet.isHD
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
    
    public func deleteWallet(wallet: KeyWalletModel, completion: @escaping (Error?) -> Void) {
        let requestWallet: NSFetchRequest<KeyWallet> = KeyWallet.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "address = %@", wallet.address)
        do {
            let results = try mainContext.fetch(requestWallet)
            guard let result = results.first else {
                completion(DataBaseError.noSuchWalletInStorage)
                return
            }
            mainContext.delete(result)
            try mainContext.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func saveTransactions(transactions: [ETHTransactionModel], forWallet wallet: KeyWalletModel, completion: @escaping(Error?) -> Void) {
        container.performBackgroundTask { (context) in
            do {
                for transaction in transactions {
                    let fr: NSFetchRequest<ETHTransaction> = ETHTransaction.fetchRequest()
                    fr.predicate = NSPredicate(format: "transactionHash = %@", transaction.transactionHash)
                    let result = try context.fetch(fr).first
                    if let result = result {
                        result.amount = transaction.amount
                        result.data = transaction.data
                        result.date = transaction.date
                        result.from = transaction.from
                        result.networkID = transaction.networkID
                        result.to = transaction.to
                        result.isPending = false
                        //Update information stored in local storage.
                        
                    } else {
                        guard let newTransaction = NSEntityDescription.insertNewObject(forEntityName: "ETHTransaction", into: context) as? ETHTransaction else {
                            DispatchQueue.main.async {
                                completion(DataBaseError.problemsWithInsertingNewEntity)
                            }
                            return
                        }
                        newTransaction.amount = transaction.amount
                        newTransaction.data = transaction.data
                        newTransaction.date = transaction.date
                        newTransaction.from = transaction.from
                        newTransaction.networkID = transaction.networkID
                        newTransaction.to = transaction.to
                        newTransaction.isPending = false
                        
                        if let contractAddress =  transaction.token?.address {
                            //In case of ERC20 tokens
                            let result = try context.fetch(self.fetchTokenRequest(withAddress: contractAddress)).first
                            if let token = result {
                                newTransaction.token = token
                            } else {
                                let newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20Token", into: context) as? ERC20Token
                                newToken?.address = transaction.token?.address
                                newToken?.decimals = transaction.token?.decimals
                                newToken?.name = transaction.token?.name
                                newToken?.symbol = transaction.token?.symbol
                                newToken?.networkID = transaction.networkID
                                newTransaction.token = newToken
                            }
                        } else {
                            //In case of custom ETH transaction
                            let result = try context.fetch(self.fetchTokenRequest(withAddress: ""))
                            if let ethToken = result.first {
                                newTransaction.token = ethToken
                            } else {
                                let newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20Token", into: context) as? ERC20Token
                                newToken?.address = ""
                                newToken?.name = "Ether"
                                newToken?.decimals = "18"
                                newToken?.symbol = "ETH"
                                newTransaction.token = newToken
                            }
                            
                        }
                        newTransaction.transactionHash = transaction.transactionHash
                        //MARK: - Fetch wallet from core data, and if there is no one wallet - create.
                        let walletCD = try context.fetch(self.fetchWalletRequest(withAddress: wallet.address)).first
                        if let walletCD = walletCD {
                            newTransaction.wallet = walletCD
                        } else {
                            let newWallet = NSEntityDescription.insertNewObject(forEntityName: "KeyWallet", into: context) as? KeyWallet
                            newWallet?.address = wallet.address
                            newWallet?.isHD = wallet.isHD
                            newWallet?.data = wallet.data
                            newWallet?.name = wallet.name
                            newWallet?.isSelected = true
                        }
                    }
                }
                try context.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                print(error)
            }
        }
    }
    
    public func getAllTransactions(forWallet wallet: KeyWalletModel, andNetwork networkID: Int64) -> [ETHTransactionModel] {
        do {
            guard let result = try mainContext.fetch(self.fetchWalletRequest(withAddress: wallet.address)).first else {return []}
            guard var transactions = result.transactions?.allObjects as? [ETHTransaction] else {return []}
            transactions = transactions.filter{$0.networkID == networkID}
            return transactions.map{
                return ETHTransactionModel(transactionHash: $0.transactionHash!, from: $0.from!, to: $0.to!, amount: $0.amount!, date: $0.date!, data: $0.data, token: $0.token.flatMap{ return ERC20TokenModel(name: $0.name!, address: $0.address!, decimals: $0.decimals!, symbol: $0.symbol!) }, networkID: $0.networkID, isPending: $0.isPending)
            }
        } catch {
            print(error)
            return []
        }
    }
    
    public func saveToken(from dict: [String : Any], completion: @escaping(Error?) -> Void) {

        container.performBackgroundTask {  (context) in
            
            do {
                let token: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
                token.predicate = NSPredicate(format: "address = %@", dict["address"] as! String)
                
                guard var newToken = NSEntityDescription.insertNewObject(forEntityName: "ERC20Token", into: context) as? ERC20Token else { return }
                
                if let entity = try self.mainContext.fetch(token).first {
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
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func saveCustomToken(with token: ERC20TokenModel?,
                                forWallet: KeyWalletModel,
                                forNetwork: Int64,
                                completion: @escaping(Error?) -> Void) {

        container.performBackgroundTask { (context) in
            do {
                guard let wallet = try context.fetch(self.fetchWalletRequest(withAddress: forWallet.address)).first else {
                    completion (NetworkErrors.couldnotParseJSON)
                    return
                }
                
                guard let token = token else {
                    completion(NetworkErrors.couldnotParseJSON)
                    return
                }
                guard let entity = NSEntityDescription.insertNewObject(forEntityName: "ERC20Token", into: context) as? ERC20Token else {
                    completion(NetworkErrors.couldnotParseJSON)
                    return
                }
                entity.address = token.address
                entity.name = token.name
                entity.symbol = token.symbol
                entity.decimals = token.decimals
                entity.isAdded = true
                entity.walletAddress = wallet.address

                //TODO
                //let networkID = Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
                let networkID = forNetwork
                entity.networkID = networkID

            
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
//    public func addToken(with token: ERC20TokenModel?,
//                         forWallet: KeyWalletModel,
//                         forNetwork: Int64,
//                         completion: @escaping(Error?) -> Void) {
//
//        container.performBackgroundTask { (context) in
//            do {
//                guard let wallet = try self.mainContext.fetch(self.fetchWalletRequest(withAddress: forWallet.address)).first else {
//                    completion (NetworkErrors.couldnotParseJSON)
//                    return
//                }
//
//                let requestToken: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
//                requestToken.predicate = NSPredicate(format: "address = %@ && networkID = %@", (token?.address) ?? "")
//
//                let entity = try self.mainContext.fetch(requestToken).first
//                entity?.setValue(true, forKey: "isAdded")
//                entity?.setValue(wallet.address, forKey: "walletAddress")
//                //let networkID = Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
//                let networkID = forNetwork
//                entity?.setValue(networkID, forKey: "networkID")
//                try context.save()
//                completion(nil)
//            } catch {
//                completion(error)
//            }
//        }
//    }
    
    
    public func getAllTokens(for wallet: KeyWalletModel, forNetwork: Int64) -> [ERC20TokenModel] {
        do {
            guard let wallet = try mainContext.fetch(self.fetchWalletRequest(withAddress: wallet.address)).first else {return []}
            let requestTokens: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
            let networkID = forNetwork
            //let networkID: Int64 = Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
        
            requestTokens.predicate = NSPredicate(format: "networkID == %@ && isAdded == %@", NSNumber(value: networkID), NSNumber(value: true))
            let results = try mainContext.fetch(requestTokens)
            let tokens = results.filter{$0.walletAddress == wallet.address}
            return tokens.map{ return ERC20TokenModel.fromCoreData(crModel: $0)}
            
        } catch {
            print(error)
            return []
        }
    }
    
    public func getToken(token: ERC20TokenModel?) -> ERC20TokenModel? {
        let requestToken: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
        requestToken.predicate = NSPredicate(format: "address = %@", (token?.address) ?? "")
        do {
            let results = try mainContext.fetch(requestToken)
            return results.map{return ERC20TokenModel.fromCoreData(crModel: $0)}.first
        } catch {
            return nil
        }
        
    }
    
    public func getTokensList(for searchingString: String) -> [ERC20TokenModel]? {
        let requestToken: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
        requestToken.predicate = NSPredicate(format: "walletAddress = %@ && (address CONTAINS[c] %@ || name CONTAINS[c] %@ || symbol CONTAINS[c] %@)", "", searchingString, searchingString, searchingString)
        do {
            let results = try mainContext.fetch(requestToken)
            return results.map{return ERC20TokenModel.fromCoreData(crModel: $0)}
        } catch {
            return nil
        }
    }
    
    public func deleteToken(token: ERC20TokenModel,
                            forWallet: KeyWalletModel,
                            forNetwork: Int64,
                            completion: @escaping (Error?) -> Void) {
        do {
            let requestToken: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
            requestToken.predicate = NSPredicate(format: "walletAddress = %@", forWallet.address)
        
            let results = try mainContext.fetch(requestToken)
            let tokens = results.filter{$0.address == token.address}
            let tokensInNetwork = tokens.filter{$0.networkID == forNetwork}
            guard let t = tokensInNetwork.first else {
                completion(nil)
                return
            }
            mainContext.delete(t)
            try mainContext.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    private func fetchTokenRequest(withAddress address: String) -> NSFetchRequest<ERC20Token> {
        let fr: NSFetchRequest<ERC20Token> = ERC20Token.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
    
    private func fetchWalletRequest(withAddress address: String) -> NSFetchRequest<KeyWallet> {
        let fr: NSFetchRequest<KeyWallet> = KeyWallet.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
    
}

enum DataBaseError: Error {
    case noSuchWalletInStorage
    case problemsWithInsertingNewEntity
}
