//
//  WalletsCoordinator.swift
//  DiveLane
//
//  Created by Anton Grigorev on 13/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class WalletsCoordinator {
    
    private let walletsService = WalletsService()
    
    func getWallets() -> [TableWallet] {
        do {
            let allWallets = try self.walletsService.getAllWallets()
            let selectedNetwork = CurrentNetwork.currentNetwork
            guard let currentWallet = CurrentWallet.currentWallet else {
                return []
            }
            var walletsArray = [TableWallet]()
            for wallet in allWallets {
                let token = try wallet.getSelectedToken(network: selectedNetwork)
                let tableWallet = TableWallet(wallet: wallet,
                                              selectedToken: token,
                                              balanceUSD: nil,
                                              isSelected: (wallet == currentWallet)
                )
                walletsArray.append(tableWallet)
            }
            return walletsArray
        } catch {
            return []
        }
    }
    
    func getDollarsBalance(for wallet: Wallet) -> String {
        do {
            let selectedNetwork = CurrentNetwork.currentNetwork
            let tokens = try wallet.getAllTokens(network: selectedNetwork)
            var dollarsWalletBalance: Double = 0
            for token in tokens {
                let balance: String
                if token == ERC20Token(ether: true) {
                    balance = try wallet.getETHbalance()
                } else {
                    balance = try wallet.getERC20balance(for: token)
                }
                let balanceInDollars: Double
                if let conversion = token.rate {
                    let resultInDouble: Double = Double(balance) ?? 0
                    let convertedAmount = Double(round(100*(conversion * resultInDouble))/100)
                    balanceInDollars = convertedAmount
                } else {
                    if let convertedRateAndChange = try? token.updateRateAndChange() {
                        balanceInDollars = convertedRateAndChange.rate
                    } else {
                        balanceInDollars = 0
                    }
                }
                dollarsWalletBalance += balanceInDollars
            }
            let stringAmount = String(dollarsWalletBalance)
            return stringAmount
        } catch {
            return getDollarsBalance(for: wallet)
        }
    }
}
