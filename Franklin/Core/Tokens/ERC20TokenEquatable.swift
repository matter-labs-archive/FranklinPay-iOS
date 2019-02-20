//
//  ERC20TokenEquatable.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

extension ERC20Token: Equatable {
    public static func ==(lhs: ERC20Token, rhs: ERC20Token) -> Bool {
        return lhs.name == rhs.name &&
            lhs.address == rhs.address &&
            lhs.decimals == rhs.decimals &&
            lhs.symbol == rhs.symbol
    }
}
