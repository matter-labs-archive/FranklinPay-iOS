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
            } else {
                let etherToken = Ether()
                do {
                    try etherToken.select()
                    _currentToken = etherToken
                    return etherToken
                } catch {
                    return nil
                }
            }
        }
        set(token) {
            if let token = token {
                do {
                    try token.select()
                    _currentToken = token
                } catch let error {
                    print("can't select token")
                }
            }
        }
    }

}
