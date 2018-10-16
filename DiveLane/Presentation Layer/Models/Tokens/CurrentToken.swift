//
//  CurrentToken.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

class CurrentToken: ERC20TokenModel {

    static var _currentToken: ERC20TokenModel?

    class var currentToken: ERC20TokenModel? {
        get {

            if _currentToken == nil {
                _currentToken = ERC20TokenModel(isEther: true)
            }
            return _currentToken
        }

        set(token) {

            _currentToken = token
        }
    }

}
