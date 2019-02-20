//
//  UserDefaultKeys.swift
//  DiveLane
//
//  Created by Anton Grigorev on 26.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public struct UserDefaultKeys {
    
    public func isFranklinAdded(for wallet: Wallet) -> Bool {
        return UserDefaults.standard.bool(forKey: "FranklinAddedForWallet\(wallet.address)")
    }
    public func setFranklinAdded(for wallet: Wallet) {
        UserDefaults.standard.set(true, forKey: "FranklinAddedForWallet\(wallet.address)")
        UserDefaults.standard.synchronize()
    }
    
    public func isXDaiAdded(for wallet: Wallet) -> Bool {
        return UserDefaults.standard.bool(forKey: "XDaiAddedForWallet\(wallet.address)")
    }
    public func setXDaiAdded(for wallet: Wallet) {
        UserDefaults.standard.set(true, forKey: "XDaiAddedForWallet\(wallet.address)")
        UserDefaults.standard.synchronize()
    }
    
    public func isBuffAdded(for wallet: Wallet) -> Bool {
        return UserDefaults.standard.bool(forKey: "BuffAddedForWallet\(wallet.address)")
    }
    public func setBuffAdded(for wallet: Wallet) {
        UserDefaults.standard.set(true, forKey: "BuffAddedForWallet\(wallet.address)")
        UserDefaults.standard.synchronize()
    }
    
    public func isDaiAdded(for wallet: Wallet) -> Bool {
        return UserDefaults.standard.bool(forKey: "DaiAddedForWallet\(wallet.address)")
    }
    public func setDaiAdded(for wallet: Wallet) {
        UserDefaults.standard.set(true, forKey: "DaiAddedForWallet\(wallet.address)")
        UserDefaults.standard.synchronize()
    }
    
    public func isEtherAdded(for wallet: Wallet) -> Bool {
        return UserDefaults.standard.bool(forKey: "EtherAddedForWallet\(wallet.address)")
    }
    public func setEtherAdded(for wallet: Wallet) {
        UserDefaults.standard.set(true, forKey: "EtherAddedForWallet\(wallet.address)")
        UserDefaults.standard.synchronize()
    }
    
    public func isBackupReady(for wallet: Wallet) -> Bool {
        return UserDefaults.standard.bool(forKey: "BackupReadyForWallet\(wallet.address)")
    }
    public func setBackupReady(for wallet: Wallet) {
        UserDefaults.standard.set(true, forKey: "BackupReadyForWallet\(wallet.address)")
        UserDefaults.standard.synchronize()
    }
    
    public func isOnboardingPassed() -> Bool {
        return UserDefaults.standard.bool(forKey: "OnboardingPassed")
    }
    public func setOnboardingPassed() {
        UserDefaults.standard.set(true, forKey: "OnboardingPassed")
        UserDefaults.standard.synchronize()
    }
    
    public func isPincodeExists() -> Bool {
        return UserDefaults.standard.bool(forKey: "PincodeExists")
    }
    public func setPincodeExists() {
        UserDefaults.standard.set(true, forKey: "PincodeExists")
        UserDefaults.standard.synchronize()
    }
    
    public func getCurrentNetwork() -> [String: Any]? {
        let networkFromUD = UserDefaults.standard.value(forKey: "CurrentNetwork") as? [String: Any]
        return networkFromUD
    }
    public func setCurrentNetwork(_ network: Web3Network) {
        UserDefaults.standard.set(["id": network.id, "name": network.name], forKey: "CurrentNetwork")
        UserDefaults.standard.synchronize()
    }
    
    public func areTokensDownloaded() -> Bool {
        return UserDefaults.standard.bool(forKey: "TokensDownloaded")
    }
    public func setTokensDownloaded() {
        UserDefaults.standard.set(true, forKey: "TokensDownloaded")
        UserDefaults.standard.synchronize()
    }
}
