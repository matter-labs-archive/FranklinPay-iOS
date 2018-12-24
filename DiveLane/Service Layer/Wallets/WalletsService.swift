//
//  WalletsService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 27/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt
import EthereumAddress
import CoreData

protocol IWalletsService {
    func getKey() throws -> HDKey
    func keystoreManager() throws -> KeystoreManager
    func importWalletWithPrivateKey(name: String?,
                                    key: String,
                                    password: String) throws -> WalletModel
    func createWallet(name: String?,
                      password: String) throws -> WalletModel
    func createHDWallet(name: String?,
                        password: String,
                        mnemonics: String) throws -> WalletModel
    func getPrivateKey(for wallet: WalletModel, password: String) throws -> String
    func generateMnemonics(bitsOfEntropy: Int) throws -> String
    
    func getSelectedWallet() throws -> WalletModel
    func saveWallet(wallet: WalletModel) throws
    func getAllWallets() throws -> [WalletModel]
    func deleteWallet(wallet: WalletModel) throws
    func selectWallet(wallet: WalletModel) throws
}

public class WalletsService: IWalletsService {
    
    public func getKey() throws -> HDKey {
        guard let wallet = try? self.getSelectedWallet(),
            !wallet.address.isEmpty else {
            throw Errors.StorageErrors.noSelectedWallet
        }
        return HDKey(name: wallet.name,
                     address: wallet.address)
    }
    
    public func keystoreManager() throws -> KeystoreManager {
        guard let wallet = try? self.getSelectedWallet(),
            let data = wallet.data else {
                if let defaultKeystore = KeystoreManager.defaultManager {
                    return defaultKeystore
                } else {
                    throw Web3Error.keystoreError(err: .invalidAccountError)
                }
        }
        if wallet.isHD {
            guard let keystore = BIP32Keystore(data) else {
                if let defaultKeystore = KeystoreManager.defaultManager {
                    return defaultKeystore
                } else {
                    throw Web3Error.keystoreError(err: .invalidAccountError)
                }
            }
            return KeystoreManager([keystore])
        } else {
            guard let keystore = EthereumKeystoreV3(data) else {
                if let defaultKeystore = KeystoreManager.defaultManager {
                    return defaultKeystore
                } else {
                    throw Web3Error.keystoreError(err: .invalidAccountError)
                }
            }
            return KeystoreManager([keystore])
        }
    }
    
    public func importWalletWithPrivateKey(name: String?,
                                           key: String,
                                           password: String) throws -> WalletModel {
        let text = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {
            throw Errors.StorageErrors.cantImportWallet
        }
        
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: password) else {
            throw Errors.StorageErrors.cantImportWallet
        }
        
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            throw Errors.StorageErrors.cantImportWallet
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            throw Errors.StorageErrors.cantImportWallet
        }
        guard let address = newWallet?.addresses?.first?.address else {
            throw Errors.StorageErrors.cantImportWallet
        }
        let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
        return walletModel
    }
    
    public func createWallet(name: String?,
                             password: String) throws -> WalletModel {
        guard let newWallet = try? EthereumKeystoreV3(password: password) else {
            throw Errors.StorageErrors.cantCreateWallet
        }
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            throw Errors.StorageErrors.cantCreateWallet
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            throw Errors.StorageErrors.cantCreateWallet
        }
        guard let address = wallet.addresses?.first?.address else {
            throw Errors.StorageErrors.cantCreateWallet
        }
        let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
        return walletModel
    }
    
    public func createHDWallet(name: String?,
                               password: String,
                               mnemonics: String) throws -> WalletModel {
        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics,
                                                password: password,
                                                mnemonicsPassword: "",
                                                language: .english), let wallet = keystore else {
            throw Errors.StorageErrors.cantCreateWallet
        }
        guard let address = wallet.addresses?.first?.address else {
            throw Errors.StorageErrors.cantCreateWallet
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            throw Errors.StorageErrors.cantCreateWallet
        }
        let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: true)
        return walletModel
    }
    
    public func getPrivateKey(for wallet: WalletModel, password: String) throws -> String {
        do {
            guard let ethereumAddress = EthereumAddress(wallet.address) else {
                throw Web3Error.walletError
            }
            guard let manager = try? keystoreManager() else {
                throw Web3Error.keystoreError(err: .invalidAccountError)
            }
            let pkData = try manager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
            return pkData.toHexString()
        } catch let error {
            throw error
        }
    }
    
    public func generateMnemonics(bitsOfEntropy: Int) throws -> String {
        guard let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy),
            let unwrapped = mnemonics else {
                throw Web3Error.keystoreError(err: .noEntropyError)
        }
        return unwrapped
    }
    
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
