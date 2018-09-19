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
