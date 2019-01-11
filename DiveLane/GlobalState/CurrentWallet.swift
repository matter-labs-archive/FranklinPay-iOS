//
//  CurrentWallet.swift
//  DiveLane
//
//  Created by Антон Григорьев on 28/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public class CurrentWallet {
    
    private static var _currentWallet: Wallet?
    private static let walletsService = WalletsService()
    
    public class var currentWallet: Wallet? {
        get {
            if let wallet = _currentWallet {
                return wallet
            }
            if let selectedWallet = try? walletsService.getSelectedWallet() {
                _currentWallet = selectedWallet
                return selectedWallet
            }
            guard let wallets = try? walletsService.getAllWallets(), let wallet = wallets.first else {
                return nil
            }
            do {
                try wallet.select()
                _currentWallet = wallet
                return wallet
            } catch {
                return nil
            }
        }
        set(wallet) {
            if let wallet = wallet {
                do {
                    try wallet.select()
                    _currentWallet = wallet
                } catch let error {
                    fatalError("Can't select wallet \(wallet.name), error: \(error.localizedDescription)")
                }
            }
        }
    }

}
