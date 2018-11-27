//
//  Transaction.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift

public struct ETHTransactionModel {
    let transactionHash: String
    let from: String
    let to: String
    let amount: String
    let date: Date
    let data: Data?
    let token: ERC20TokenModel? // nil if it is custom ETH transaction
    let networkID: Int64
    var isPending = false
}

public struct TransactionInfo {
    var contractAddress: String
    var transactionIntermediate: TransactionIntermediate
    var methodName: String
}

public enum TransactionType {
    case custom
    case arbitraryMethodWithParams
}
