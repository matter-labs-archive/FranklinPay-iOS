//
//  SettingsTableViewSections.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

public struct SettingsModel {
    let title: String
    let subtitle: String?
    let image: UIImage
    let currentState: Any?
    let notification: Bool
    
    init(_ setting: MainSettings) {
        switch setting {
        case .privateKey:
            self.title = "Private key"
            self.subtitle = "Don't give it to anyone!"
            self.image = UIImage(named: "backup") ?? UIImage()
            self.currentState = nil
            self.notification = false
        case .backup:
            self.title = "Backup now"
            self.subtitle = "Your money is at risk!"
            self.image = UIImage(named: "backup") ?? UIImage()
            self.currentState = nil
            self.notification = true
        case .wallet:
            self.title = "Current wallet"
            self.subtitle = CurrentWallet.currentWallet?.address.hideExtraSymbolsInAddress()
            self.image = UIImage(named: "wallet_settings") ?? UIImage()
            self.currentState = nil
            self.notification = false
        case .network:
            self.title = "Current network"
            self.subtitle = CurrentNetwork.currentNetwork.name
            self.image = UIImage(named: "network") ?? UIImage()
            self.currentState = nil
            self.notification = false
        case .changePincode:
            self.title = "Change PIN"
            self.subtitle = ""
            self.image = UIImage(named: "pincode") ?? UIImage()
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

extension SettingsModel: Equatable {
    public static func ==(lhs: SettingsModel, rhs: SettingsModel) -> Bool {
        return lhs.title == rhs.title
    }
}
