//
//  TokensCoordinator.swift
//  DiveLane
//
//  Created by Anton Grigorev on 24/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public class EtherCoordinator {
    
    private let tokensService = TokensService()
    private let walletsService = WalletsService()
    
    func getTokens() -> [TableToken] {
        let selectedNetwork = CurrentNetwork.currentNetwork
        guard let wallet = CurrentWallet.currentWallet else {
            return []
        }
        if CurrentToken.currentToken == nil {
            CurrentToken.currentToken = ERC20Token(franklin: true)
        }
        guard let tokens = try? wallet.getAllTokens(network: selectedNetwork) else {
            return []
        }
        let currentToken = CurrentToken.currentToken ?? ERC20Token(franklin: true)
        let tableTokens: [TableToken] = tokens.map {
            TableToken(token: $0,
                       inWallet: wallet,
                       isSelected: ($0 == currentToken))
        }
        return tableTokens
    }
    
    func getBalance(for token: ERC20Token, wallet: Wallet) -> String {
        do {
            let balance: String
            if token == ERC20Token(ether: true) {
                balance = try wallet.getETHbalance()
            } else {
                balance = try wallet.getERC20balance(for: token)
            }
            return balance
        } catch {
            return getBalance(for: token, wallet: wallet)
        }
    }
    
    // TODO: - need to fix
    func getBalanceInDollars(for token: ERC20Token, withBalance: String) -> String {
        do {
            let rateAndChange = try token.updateRateAndChange()
            let resultInDouble: Double = Double(withBalance) ?? 0
            let convertedAmount = Double(round(100*(rateAndChange.rate * resultInDouble))/100)
            let stringAmount =  String(convertedAmount)
            return stringAmount
//            if let conversion = RatesState.shared().rates[token.symbol.uppercased()] {
//                let resultInDouble: Double = Double(withBalance) ?? 0
//                let convertedAmount = Double(round(100*(conversion * resultInDouble))/100)
//                let stringAmount =  String(convertedAmount)
//                return stringAmount
//            } else {
//                _ = try token.updateConversionRate()
//                return getBalanceInDollars(for: token, withBalance: withBalance)
//            }
        } catch {
            return "0"
        }
    }
    
}
