//
//  CurrentToken.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public class CurrentToken: ERC20Token {

    private static var _currentToken: ERC20Token?
    private static let tokensService = TokensService()

    public class var currentToken: ERC20Token? {
        get {
            if let token = _currentToken {
                return token
            }
            do {
                guard let wallet = CurrentWallet.currentWallet else {
                    fatalError("Can't select wallet")
                }
                if let token = try? wallet.getSelectedToken(network: CurrentNetwork.currentNetwork) {
                    return token
                }
                let franklinToken = Franklin()
                try franklinToken.select(in: wallet, network: CurrentNetwork.currentNetwork)
                _currentToken = franklinToken
                return franklinToken
            } catch let error {
                fatalError("Can't get selected token, error: \(error.localizedDescription)")
            }
        }
        set(token) {
            if let token = token {
                do {
                    guard let wallet = CurrentWallet.currentWallet else {
                        fatalError("Can't select wallet")
                    }
                    try token.select(in: wallet, network: CurrentNetwork.currentNetwork)
                    _currentToken = token
                } catch let error {
                    fatalError("Can't select token \(token.address), error: \(error.localizedDescription)")
                }
            }
        }
    }

}
