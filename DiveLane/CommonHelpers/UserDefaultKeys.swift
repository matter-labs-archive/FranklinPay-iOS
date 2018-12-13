//
//  UserDefaultKeys.swift
//  DiveLane
//
//  Created by Anton Grigorev on 26.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public struct UserDefaultKeys {
    
    public var isEtherAdded = UserDefaults.standard.bool(forKey: "etherAddedForWallet\((try? WalletsService().getSelectedWallet().address) ?? "")")
    public var isOnboardingPassed = UserDefaults.standard.bool(forKey: "isOnboardingPassed")
    public var tokensDownloaded = UserDefaults.standard.bool(forKey: "tokensDownloaded")
    public var currentNetwork = UserDefaults.standard.object(forKey: "currentNetwork")
    public var currentWeb = UserDefaults.standard.object(forKey: "currentWeb")

    public func setEtherAdded() {
        guard let address = try? WalletsService().getSelectedWallet().address else {
            return
        }
        UserDefaults.standard.set(true, forKey: "etherAddedForWallet\(address)")
    }

    public func setTokensDownloaded() {
        UserDefaults.standard.set(true, forKey: "tokensDownloaded")
    }
}
