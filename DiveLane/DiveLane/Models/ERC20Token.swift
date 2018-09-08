//
//  ERC20Token.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

class ERC20TokenModel {
    let name: String
    let address: String
    let decimals: String
    let symbol: String
    
    init(token: ERC20Token) {
        self.name = token.name ?? ""
        self.address = token.address ?? ""
        self.decimals = token.decimals ?? ""
        self.symbol = token.symbol ?? ""
    }
    
    init(name: String,
         address: String,
         decimals: String,
         symbol: String) {
        self.name = name
        self.address = address
        self.decimals = decimals
        self.symbol = symbol
    }
}

extension ERC20TokenModel: Equatable {
    static func == (lhs: ERC20TokenModel, rhs: ERC20TokenModel) -> Bool {
        return
            lhs.name == rhs.name &&
                lhs.address == rhs.address &&
                lhs.decimals == rhs.decimals &&
                lhs.symbol == rhs.symbol
    }
}
