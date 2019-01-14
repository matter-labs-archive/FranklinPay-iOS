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
    func importWalletWithPrivateKey(name: String,
                                    key: String,
                                    password: String) throws -> Wallet
    func createWallet(name: String,
                      password: String) throws -> Wallet
    func createHDWallet(name: String,
                        password: String,
                        mnemonics: String) throws -> Wallet
    func generateMnemonics(bitsOfEntropy: Int) throws -> String
}

protocol IWalletsStorage {
    func getSelectedWallet() throws -> Wallet
    func getAllWallets() throws -> [Wallet]
}

public class WalletsService: IWalletsService {
    
    public func importWalletWithPrivateKey(name: String,
                                           key: String,
                                           password: String) throws -> Wallet {
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
        let w = Wallet(address: address,
                            data: keyData,
                            name: name,
                            isHD: false)
        return w
    }
    
    public func createWallet(name: String,
                             password: String) throws -> Wallet {
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
        let w = Wallet(address: address,
                            data: keyData,
                            name: name,
                            isHD: false)
        return w
    }
    
    public func createHDWallet(name: String,
                               password: String,
                               mnemonics: String) throws -> Wallet {
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
        let w = Wallet(address: address,
                       data: keyData,
                       name: name,
                       isHD: true)
        return w
    }
    
    public func generateMnemonics(bitsOfEntropy: Int) throws -> String {
        guard let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy),
            let unwrapped = mnemonics else {
                throw Web3Error.keystoreError(err: .noEntropyError)
        }
        return unwrapped
    }
}

extension WalletsService: IWalletsStorage {
    
    public func getSelectedWallet() throws -> Wallet {
        let requestWallet: NSFetchRequest<WalletModel> = WalletModel.fetchRequest()
        requestWallet.predicate = NSPredicate(format: "isSelected = %@", NSNumber(value: true))
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            guard let result = results.first else {
                throw Errors.StorageErrors.noSelectedWallet
            }
            return try Wallet(crModel: result)
            
        } catch let error {
            throw error
        }
    }
    
    public func getAllWallets() throws -> [Wallet] {
        let requestWallet: NSFetchRequest<WalletModel> = WalletModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestWallet)
            return try results.map {
                return try Wallet(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    private func fetchWalletRequest(with address: String) -> NSFetchRequest<WalletModel> {
        let fr: NSFetchRequest<WalletModel> = WalletModel.fetchRequest()
        fr.predicate = NSPredicate(format: "address = %@", address)
        return fr
    }
}
