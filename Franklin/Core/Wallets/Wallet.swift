//
//  KeyWallet.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt
import EthereumAddress

protocol IWallet {
    func changeWeb3(_ web3: web3)
    func getPrivateKey(withPassword: String) throws -> String
    func getHDKey() -> HDKey
    func getPassword() throws -> String
    func addPassword(_ password: String) throws
}

public class Wallet: IWallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
    var plasmaID: String?
    var backup: String?
    
    internal func request(url: URL,
                          data: Data?,
                          method: Method,
                          contentType: ContentType) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        request.httpMethod = method.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return request
    }
    
    internal var session: URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig,
                                 delegate: nil,
                                 delegateQueue: nil)
        return session
    }
    
    internal var web3Instance: web3? {
        get {
            let web3 = CurrentNetwork.currentWeb
            let keystoreManager = self.keystoreManager
            web3?.addKeystoreManager(keystoreManager)
            return web3
        }
        set (web3) {
            let keystoreManager = self.keystoreManager
            web3Instance?.addKeystoreManager(keystoreManager)
        }
    }
    
    public func changeWeb3(_ web3: web3) {
        self.web3Instance = web3
    }
    
    public var keystoreManager: KeystoreManager? {
        if self.isHD {
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

    public init(crModel: WalletModel) throws {
        guard let address = crModel.address,
            let data = crModel.data,
            let name = crModel.name else {
                throw Errors.WalletErrors.cantGetWallet
        }
        let backup = crModel.backup
        let plasmaID = crModel.plasmaID
        
        self.address = address
        self.data = data
        self.name = name
        self.isHD = crModel.isHD
        self.backup = backup
        self.plasmaID = plasmaID
    }
    
    public init(address: String,
                data: Data,
                name: String,
                isHD: Bool,
                backup: String?,
                plasmaID: String?) {
        self.address = address
        self.data = data
        self.name = name
        self.isHD = isHD
        self.backup = backup
        self.plasmaID = plasmaID
    }
    
    public init(wallet: Wallet) {
        self.address = wallet.address
        self.data = wallet.data
        self.name = wallet.name
        self.isHD = wallet.isHD
        self.backup = wallet.backup
        self.plasmaID = wallet.plasmaID
    }
    
    public func getPrivateKey(withPassword: String) throws -> String {
        do {
            guard let ethereumAddress = EthereumAddress(self.address) else {
                throw Errors.CommonErrors.wrongAddress
            }
            guard let manager = self.keystoreManager else {
                throw Errors.CommonErrors.wrongKeystore
            }
            let pkData = try manager.UNSAFE_getPrivateKeyData(password: withPassword, account: ethereumAddress)
            return pkData.toHexString()
        } catch let error {
            throw error
        }
    }
    
    public func getHDKey() -> HDKey {
        return HDKey(name: self.name,
                     address: self.address)
    }
    
    public func getPassword() throws -> String {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                                                    account: "\(self.address)-password",
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return keychainPassword
        } catch let error {
            throw error
        }
    }
    
    public func addPassword(_ password: String) throws {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                                                    account: "\(self.address)-password",
                                                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password)
        } catch let error {
            throw error
        }
    }
    
    public func addMnemonic(_ mnemonic: String) throws {
        do {
            let passphraseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassphrase,
                                                      account: "\(self.address)-mnemonic",
                                                      accessGroup: KeychainConfiguration.accessGroup)
            try passphraseItem.savePassword(mnemonic)
        } catch let error {
            throw error
        }
    }
    
    public func getMnemonic() throws -> String {
        do {
            let passphraseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassphrase,
                                                      account: "\(self.address)-mnemonic",
                                                      accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassphrase = try passphraseItem.readPassword()
            return keychainPassphrase
        } catch let error {
            throw error
        }
    }
}
