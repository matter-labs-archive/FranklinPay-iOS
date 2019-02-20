//
//  ETHTransactionEquatable.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

extension ETHTransaction: Equatable {
    public static func ==(lhs: ETHTransaction, rhs: ETHTransaction) -> Bool {
        return lhs.transactionHash == rhs.transactionHash
    }
}
