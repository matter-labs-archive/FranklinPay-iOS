//
//  Transaction.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift

struct ETHTransactionModel {
    let from: String
    let to: String
    let amount: String
    let date: Date
    let token: ERC20TokenModel
    let key: HDKey
    var isPending = false
}

struct TransactionInfo {
    var contractAddress: String
    //var transactionIntermediate: TransactionIntermediate
    var methodName: String
}

enum TransactionType {
    case custom
    case arbitraryMethodWithParams
}
