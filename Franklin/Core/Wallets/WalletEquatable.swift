//
//  WalletEquatable.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

extension Wallet: Equatable {
    public static func ==(lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.address == rhs.address
    }
}
