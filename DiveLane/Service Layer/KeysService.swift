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
    func createNewHDWallet(withName: String,
                           password: String,
                           mnemonics: String,
                           completion: @escaping (KeyWalletModel?, Error?) -> Void)
    func getWalletPrivateKey(password: String) -> String?
    func getPrivateKey(forWallet wallet: KeyWalletModel, password: String) -> String?
    func generateMnemonics(bitsOfEntropy: Int) -> String
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
        guard let selectedWallet = selectedWallet(), let data = selectedWallet.data else {
            return KeystoreManager.defaultManager!
        }
        if selectedWallet.isHD {
            return KeystoreManager([BIP32Keystore(data)!])
        } else {
            return KeystoreManager([EthereumKeystoreV3(data)!])
        }
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
        let walletModel = KeyWalletModel(address: address, data: keyData, name: withName ?? "", isHD: false)
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
        let walletModel = KeyWalletModel(address: address, data: keydata, name: withName ?? "", isHD: false)
        completion(walletModel, nil)
    }

    func createNewHDWallet(withName name: String, password: String, mnemonics: String, completion: @escaping (KeyWalletModel?, Error?) -> Void) {
        guard let keystore = try? BIP32Keystore(mnemonics: mnemonics,
                password: password,
                mnemonicsPassword: "",
                language: .english), let wallet = keystore else {
            return
        }
        guard let address = wallet.addresses?.first?.address else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        guard let keyData = try? JSONEncoder().encode(wallet.keystoreParams) else {
            completion(nil, WalletSavingError.couldNotCreateTheWallet)
            return
        }
        let walletModel = KeyWalletModel(address: address, data: keyData, name: name, isHD: true)
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

    public func getPrivateKey(forWallet wallet: KeyWalletModel, password: String) -> String? {
        do {
            guard let ethereumAddress = EthereumAddress(wallet.address) else {
                return nil
            }
            let pkData = try keystoreManager().UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress)
            return pkData.toHexString()
        } catch {
            print(error)
            return nil
        }
    }

    public func generateMnemonics(bitsOfEntropy: Int) -> String {
        guard let mnemonics = try? BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy),
              let unwrapped = mnemonics else {
            return ""
        }
        return unwrapped
    }
}
