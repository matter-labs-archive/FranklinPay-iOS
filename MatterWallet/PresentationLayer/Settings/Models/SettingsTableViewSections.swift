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
    let image: UIImage
    let currentState: Any
    
    init(_ setting: MainSettings) {
        switch setting {
        case .wallet:
            self.title = "Wallet"
            self.image = UIImage(named: "wallet_gray")!
            self.currentState = CurrentWallet.currentWallet!
        case .network:
            self.title = "Network"
            self.image = UIImage(named: "ether")!
            self.currentState = CurrentNetwork.currentNetwork
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
        return [MainSetting(.wallet),
                MainSetting(.network)]
    }
}

public enum MainSettings {
    case network
    case wallet
}
