//
//  SettingsInteractor.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class SettingInteractor {
    
    let userKeys = UserDefaultKeys()
    
    func getMainSettings() -> [SettingsModel] {
        guard let currentWallet = CurrentWallet.currentWallet else {
            return []
        }
        var settings = [SettingsModel(.wallet),
                        SettingsModel(.network)]
        if !userKeys.isPincodeExists() {
            settings.append(SettingsModel(.pincode))
        }
        if !userKeys.isBackupReady(for: currentWallet) {
            settings.append(SettingsModel(.backup))
        }
        return settings.reversed()
    }
}
