//
//  KeysService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

protocol IKeysService {
    func selectedWallet() -> KeyWalletModel?
    func selectedKey() -> HDKey?
    func keystoreManager() -> KeystoreManager
    func addNewWalletWithPrivateKey(withName: String?,
                                    key: String,
                                    password: String,
                                    completion: @escaping (KeyWalletModel?, Error?) -> Void)
    func createNewWallet(withName: String?,
                         password: String,
                         completion: @escaping (KeyWalletModel?, Error?) -> Void)
    func getWalletPrivateKey(password: String) -> String?
}

class KeysService: IKeysService {
    
    let localStorage = LocalDatabase()
    
    public func selectedWallet() -> KeyWalletModel? {
        return localStorage.getWallet()
    }
    
    public func selectedKey() -> HDKey? {
        guard let selectedWallet = selectedWallet(), !selectedWallet.address.isEmpty else {
            return nil
        }
        return HDKey(name: selectedWallet.name, address: selectedWallet.address)
    }
    
    public func keystoreManager() -> KeystoreManager {
        guard let selectedAddress = selectedWallet(), let data = selectedAddress.data else {
            return KeystoreManager.defaultManager!
        }
        return KeystoreManager([EthereumKeystoreV3(data)!])
    }
    
    public func addNewWalletWithPrivateKey(withName: String?,
                                    key: String,
                                    password: String,
                                    completion: @escaping (KeyWalletModel?, Error?) -> Void) {
        let text = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data.fromHex(text) else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        
        guard let newWallet = try? EthereumKeystoreV3(privateKey: data, password: password) else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        guard let address = newWallet?.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotSaveTheWallet)
            return
        }
        let walletModel = KeyWalletModel(address: address, data: keyData, name: withName ?? "")
        completion(walletModel, nil)
    }
    
    public func createNewWallet(withName: String?,
                         password: String,
                         completion: @escaping (KeyWalletModel?, Error?) -> Void) {
        guard let newWallet = try? EthereumKeystoreV3(password: password) else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        guard let wallet = newWallet, wallet.addresses?.count == 1 else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        guard let keydata = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        guard let address = wallet.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        let walletModel = KeyWalletModel(address: address, data: keydata, name: withName ?? "")
        completion(walletModel, nil)
    }
    
    public func getWalletPrivateKey(password: String) -> String? {
        do {
            let data = try keystoreManager().UNSAFE_getPrivateKeyData(password: password, account: EthereumAddress((selectedWallet()?.address)!)!)
            return data.toHexString()
        } catch {
            print(error)
            return nil
        }
    }
}
