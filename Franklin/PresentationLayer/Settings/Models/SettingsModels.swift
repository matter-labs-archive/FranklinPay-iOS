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
            self.image = UIImage(named: "backup")!
            self.currentState = nil
            self.notification = true
        case .wallet:
            self.title = "Current wallet"
            self.subtitle = nil
            self.image = UIImage(named: "wallet_gray")!
            self.currentState = CurrentWallet.currentWallet
            self.notification = false
        case .network:
            self.title = "Network"
            self.subtitle = nil
            self.image = UIImage(named: "ether")!
            self.currentState = CurrentNetwork.currentNetwork
            self.notification = false
        case .pincode:
            self.title = "Set up PIN code"
            self.subtitle = "Protect your phone"
            self.image = UIImage(named: "pincode")!
            self.currentState = nil
            self.notification = false
        case .topup:
            self.title = "Top up"
            self.subtitle = nil
            self.image = UIImage(named: "topup")!
            self.currentState = nil
            self.notification = false
        case .help:
            self.title = "Get help"
            self.subtitle = nil
            self.image = UIImage(named: "help")!
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
    func getMainSettings() -> [MainSetting] {
        if CurrentWallet.currentWallet?.backup != nil {
            return [MainSetting(.backup),
                    MainSetting(.pincode),
                    MainSetting(.topup),
                    MainSetting(.help)]
        } else {
            return [MainSetting(.pincode),
                    MainSetting(.topup),
                    MainSetting(.help)]
        }
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
