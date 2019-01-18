//
//  TableWallet.swift
//  DiveLane
//
//  Created by Anton Grigorev on 12/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

struct TableWallet {
    var wallet: Wallet
    var selectedToken: ERC20Token
    var balanceUSD: String?
    var isSelected: Bool
}
