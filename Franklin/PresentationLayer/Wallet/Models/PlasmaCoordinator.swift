//
//  UTXOsCoordinator.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress
import Web3swift
import BigInt

public class PlasmaCoordinator {
    
    private let tokensService = TokensService()
    private let walletsService = WalletsService()
    
    func getFranklin() -> [TableToken] {
        let selectedNetwork = CurrentNetwork.currentNetwork
        let mainnet = selectedNetwork.id == Int64(Networks.Mainnet.chainID)
        let testnet = !mainnet
            && selectedNetwork.id == Int64(Networks.Rinkeby.chainID)
        if !testnet && !mainnet {
            return []
        }
        guard let wallet = CurrentWallet.currentWallet else {
            return []
        }
        if CurrentToken.currentToken == nil {
            CurrentToken.currentToken = ERC20Token(franklin: true)
        }
        // TODO : - GET FRANKLIN
        let franklin = ERC20Token(franklin: true)
        let franklinTableToken = TableToken(token: franklin,
                                            inWallet: wallet,
                                            isSelected: (franklin == CurrentToken.currentToken))
        return [franklinTableToken]
    }
    
    func getBalance(wallet: Wallet) -> String {
        do {
            // TODO : - GET FRANKLIN BALANCE
            return "0.00"
        } catch {
            return getBalance(wallet: wallet)
        }
    }
    
}
