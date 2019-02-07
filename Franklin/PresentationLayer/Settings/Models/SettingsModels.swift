//
//  SettingsTableViewSections.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

public enum SettingsTableViewSections: Int {
    case main = 0
}

public struct MainSetting {
    let title: String
    let subtitle: String?
    let image: UIImage
    let currentState: Any?
    let notification: Bool
    
    init(_ setting: MainSettings) {
        switch setting {
        case .backup:
            self.title = "Backup now"
            self.subtitle = "Your money are at risk!"
            self.image = UIImage(named: "backup") ?? UIImage()
            self.currentState = nil
            self.notification = true
        case .wallet:
            self.title = "Current wallet"
            self.subtitle = CurrentWallet.currentWallet?.address
            self.image = UIImage(named: "wallet_settings") ?? UIImage()
            self.currentState = nil
            self.notification = false
        case .network:
            self.title = "Current network"
            self.subtitle = CurrentNetwork.currentNetwork.name
            self.image = UIImage(named: "network") ?? UIImage()
            self.currentState = nil
            self.notification = false
        case .pincode:
            self.title = "Set up PIN code"
            self.subtitle = "Protect your phone"
            self.image = UIImage(named: "pincode") ?? UIImage()
            self.currentState = nil
            self.notification = false
        case .topup:
            self.title = "Top up"
            self.subtitle = nil
            self.image = UIImage(named: "topup") ?? UIImage()
            self.currentState = nil
            self.notification = false
        case .help:
            self.title = "Get help"
            self.subtitle = nil
            self.image = UIImage(named: "help") ?? UIImage()
            self.currentState = nil
            self.notification = false
        }
    }
}

extension MainSetting: Equatable {
    public static func ==(lhs: MainSetting, rhs: MainSetting) -> Bool {
        return lhs.title == rhs.title
    }
}

public class SettingInteractor {
    
    let userKeys = UserDefaultKeys()
    
    func getMainSettings() -> [MainSetting] {
        guard let currentWallet = CurrentWallet.currentWallet else {
            return []
        }
        var settings = [MainSetting(.help),
                        MainSetting(.topup),
                        MainSetting(.wallet),
                        MainSetting(.network)]
        if !userKeys.isPincodeExists() {
            settings.append(MainSetting(.pincode))
        }
        if !userKeys.isBackupReady(for: currentWallet) {
            settings.append(MainSetting(.backup))
        }
        return settings.reversed()
    }
}

public enum MainSettings {
    case backup
    case network
    case wallet
    case pincode
    case help
    case topup
}
