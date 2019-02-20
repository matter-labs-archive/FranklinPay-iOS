//
//  WalletsCoordinator.swift
//  DiveLane
//
//  Created by Anton Grigorev on 13/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import Web3swift

public class WalletsCoordinator {
    
    private let walletsService = WalletsService()
    
    func getWallets() -> [TableWallet] {
        do {
            let allWallets = try self.walletsService.getAllWallets()
            //let selectedNetwork = CurrentNetwork.currentNetwork
            guard let currentWallet = CurrentWallet.currentWallet else {
                return []
            }
            var walletsArray = [TableWallet]()
            for wallet in allWallets {
                let tableWallet = TableWallet(wallet: wallet,
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
            let web3 = CurrentNetwork().isXDai() ? Web3.InfuraMainnetWeb3() : nil
            let tokens = try wallet.getAllTokens(network: selectedNetwork)
            var dollarsWalletBalance: Double = 0
            for token in tokens {
                let balance: String
                if let tBalance = token.balance {
                    balance = tBalance
                } else {
                    if token.isEther() {
                        balance = try wallet.getETHbalance(web3instance: web3)
                    } else if token.isFranklin() {
                        balance = try wallet.getFranklinBalance()
                    } else if CurrentNetwork().isXDai() && token.isXDai() {
                        balance = try wallet.getXDAIBalance()
                    } else if CurrentNetwork().isXDai() && !(token.isDai() || token.isEther()) {
                        balance = token.balance ?? "0.0"
                    } else {
                        balance = try wallet.getERC20balance(for: token, web3instance: web3)
                    }
                }
                let balanceInDollars: Double
                let noNeedToConvert = token.isFranklin() || token.isXDai() || CurrentNetwork().isXDai() && !(token.isDai() || token.isEther())
                if noNeedToConvert {
                    balanceInDollars = Double(balance) ?? 0
                } else {
                    if let conversion = try? token.updateRateAndChange() {
                        let resultInDouble: Double = Double(balance) ?? 0
                        let convertedAmount = Double(round(100*(conversion.rate * resultInDouble))/100)
                        balanceInDollars = convertedAmount
                    } else {
                        balanceInDollars = 0
                    }
                }
                dollarsWalletBalance += balanceInDollars
            }
            let shortend = Double(round(1000*dollarsWalletBalance)/1000)
            let stringAmount = String(shortend)
            return stringAmount
        } catch {
            return getDollarsBalance(for: wallet)
        }
    }
}
