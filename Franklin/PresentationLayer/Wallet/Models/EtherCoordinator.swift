//
//  TokensCoordinator.swift
//  DiveLane
//
//  Created by Anton Grigorev on 24/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress
import Web3swift
import BigInt

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
            let web3 = CurrentNetwork().isXDai() ? Web3.InfuraMainnetWeb3() : nil
            let balance: String
            if token.isEther() {
                balance = try wallet.getETHbalance(web3instance: web3)
            } else if token.isFranklin() {
                balance = try wallet.getFranklinBalance()
            } else {
                balance = try wallet.getERC20balance(for: token, web3instance: web3)
            }
            return balance
        } catch {
            return "-"
        }
    }
    
//    func getFranklin() -> [TableToken] {
//        let selectedNetwork = CurrentNetwork.currentNetwork
//        let mainnet = selectedNetwork.id == Int64(Networks.Mainnet.chainID)
//        let testnet = !mainnet
//            && selectedNetwork.id == Int64(Networks.Rinkeby.chainID)
//        if !testnet && !mainnet {
//            return []
//        }
//        guard let wallet = CurrentWallet.currentWallet else {
//            return []
//        }
//        if CurrentToken.currentToken == nil {
//            CurrentToken.currentToken = ERC20Token(franklin: true)
//        }
//        // TODO : - GET FRANKLIN
//        let franklin = ERC20Token(franklin: true)
//        let franklinTableToken = TableToken(token: franklin,
//                                            inWallet: wallet,
//                                            isSelected: (franklin == CurrentToken.currentToken))
//        return [franklinTableToken]
//    }
    
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
