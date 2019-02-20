//
//  ExpandableWallets.swift
//  DiveLane
//
//  Created by Anton Grigorev on 19.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public struct TableToken {
    var token: ERC20Token
    var inWallet: Wallet
    var isSelected: Bool
}

extension TableToken: Equatable {
    public static func ==(lhs: TableToken, rhs: TableToken) -> Bool {
        return lhs.token == rhs.token &&
            lhs.inWallet == rhs.inWallet
    }
}
