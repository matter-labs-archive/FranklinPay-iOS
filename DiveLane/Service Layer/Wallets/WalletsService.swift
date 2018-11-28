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

protocol IWalletsService {
    func getSelectedWallet() -> WalletModel?
    func getKey() -> HDKey?
    func keystoreManager() -> KeystoreManager?
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
}

class WalletsService: IWalletsService {
    let walletsStorage = WalletsStorage()
    
    public func getSelectedWallet() -> WalletModel? {
        guard let wallet = try? walletsStorage.getSelectedWallet() else {
            return nil
        }
        return wallet
    }
    
    public func getKey() -> HDKey? {
        guard let wallet = self.getSelectedWallet(),
            !wallet.address.isEmpty else {
            return nil
        }
        return HDKey(name: wallet.name,
                     address: wallet.address)
    }
    
    public func keystoreManager() -> KeystoreManager? {
        guard let wallet = self.getSelectedWallet(), let data = wallet.data else {
            return KeystoreManager.defaultManager
        }
        if wallet.isHD {
            guard let keystore = BIP32Keystore(data) else {
                return KeystoreManager.defaultManager
            }
            return KeystoreManager([keystore])
        } else {
            guard let keystore = EthereumKeystoreV3(data) else {
                return KeystoreManager.defaultManager
            }
            return KeystoreManager([keystore])
        }
    }
    
    public func importWalletWithPrivateKey(name: String?,
                                           key: String,
                                           password: String) throws -> WalletModel {
        let text = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {
            throw StorageErrors.cantImportWallet
        }
        
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: password) else {
            throw StorageErrors.cantImportWallet
        }
        
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            throw StorageErrors.cantImportWallet
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            throw StorageErrors.cantImportWallet
        }
        guard let address = newWallet?.addresses?.first?.address else {
            throw StorageErrors.cantImportWallet
        }
        let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
        return walletModel
    }
    
    public func createWallet(name: String?,
                             password: String) throws -> WalletModel {
        guard let newWallet = try? EthereumKeystoreV3(password: password) else {
            throw StorageErrors.cantCreateWallet
        }
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            throw StorageErrors.cantCreateWallet
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            throw StorageErrors.cantCreateWallet
        }
        guard let address = wallet.addresses?.first?.address else {
            throw StorageErrors.cantCreateWallet
        }
        let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
        return walletModel
    }
    
    func createHDWallet(name: String?,
                        password: String,
                        mnemonics: String) throws -> WalletModel {
        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics,
                                                password: password,
                                                mnemonicsPassword: "",
                                                language: .english), let wallet = keystore else {
            throw StorageErrors.cantCreateWallet
        }
        guard let address = wallet.addresses?.first?.address else {
            throw StorageErrors.cantCreateWallet
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            throw StorageErrors.cantCreateWallet
        }
        let walletModel = WalletModel(address: address, data: keyData, name: name ?? "", isHD: false)
        return walletModel
    }
    
    public func getPrivateKey(for wallet: WalletModel, password: String) throws -> String {
        do {
            guard let ethereumAddress = EthereumAddress(wallet.address) else {
                throw Web3Error.walletError
            }
            guard let manager = keystoreManager() else {
                throw Web3Error.keystoreError(err: .invalidAccountError)
            }
            let pkData = try manager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
            return pkData.toHexString()
        } catch let error{
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
}
