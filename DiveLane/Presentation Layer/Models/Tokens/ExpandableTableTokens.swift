//
//  ExpandableWallets.swift
//  DiveLane
//
//  Created by Anton Grigorev on 19.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

struct ExpandableTableTokens {
    var isExpanded: Bool
    var tokens: [TableToken]
}

struct TableToken {
    let token: ERC20TokenModel
    let inWallet: KeyWalletModel
    var isSelected: Bool
}

extension TableToken: Equatable {
    static func ==(lhs: TableToken, rhs: TableToken) -> Bool {
        return
        lhs.token == rhs.token &&
                lhs.inWallet == rhs.inWallet
    }
}
