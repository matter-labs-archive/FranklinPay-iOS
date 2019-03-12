//
//  WalletCreating.swift
//  Franklin
//
//  Created by Anton on 25/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class WalletCreating {
    
    internal let walletsService = WalletsService()
    internal let userDefaults = UserDefaultKeys()
    internal let appController = AppController()
    internal let tokensService = TokensService()
    
    internal let name = Constants.Wallet.newName
    internal let password = Constants.Wallet.newPassword
    
    func importWalletWithPrivateKey(key: String) throws -> Wallet {
        do {
            let wallet = try self.walletsService.importWalletWithPrivateKey(name: name,
                                                                        key: key,
                                                                        password: password)
            try wallet.save()
            try wallet.addPassword(password)
            return wallet
        } catch let error {
            throw error
        }
    }
    
    func importWalletWithPassphrase(passphrase: String) throws -> Wallet {
        do {
            let wallet = try self.walletsService.createHDWallet(name: name,
                                                                password: password,
                                                                mnemonics: passphrase,
                                                                backupNeeded: false)
            try wallet.save()
            try wallet.addPassword(password)
            return wallet
        } catch let error {
            throw error
        }
    }
    
    func createWallet() throws -> Wallet {
        do {
            let mnemonicFrase = try self.walletsService.generateMnemonics(bitsOfEntropy: 128)
            let wallet = try self.walletsService.createHDWallet(name: name,
                                                                password: password,
                                                                mnemonics: mnemonicFrase,
                                                                backupNeeded: true)
            try wallet.save()
            try wallet.addPassword(password)
            try wallet.addMnemonic(mnemonicFrase)
            return wallet
        } catch let error {
            throw error
        }
    }
    
    func prepareWallet(_ wallet: Wallet) throws {
        CurrentWallet.currentWallet = wallet
        CurrentNetwork.currentNetwork = Web3Network(network: .Mainnet)
        let tokensDownloaded = self.userDefaults.areTokensDownloaded()
        let etherAdded = self.userDefaults.isEtherAdded(for: wallet)
        let franklinAdded = self.userDefaults.isFranklinAdded(for: wallet)
        let daiAdded = self.userDefaults.isDaiAdded(for: wallet)
        let xdaiAdded = self.userDefaults.isXDaiAdded(for: wallet)
        let buffAdded = self.userDefaults.isBuffAdded(for: wallet)
        if !tokensDownloaded {
            do {
                try self.tokensService.downloadAllAvailableTokensIfNeeded()
                self.userDefaults.setTokensDownloaded()
            } catch let error {
                throw error
            }
        }
        if !xdaiAdded {
            do {
                try self.appController.addXDai(for: wallet)
            } catch let error {
                throw error
            }
        }
        if !franklinAdded {
            do {
                try self.appController.addFranklin(for: wallet)
            } catch let error {
                throw error
            }
        }
        if !etherAdded {
            do {
                try self.appController.addEther(for: wallet)
            } catch let error {
                throw error
            }
        }
        if !daiAdded {
            do {
                try self.appController.addDai(for: wallet)
            } catch let error {
                throw error
            }
        }
        if !buffAdded {
            do {
                try self.appController.addBuff(for: wallet)
            } catch let error {
                throw error
            }
        }
    }
    
}
