//
//  Transaction.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift

public class ETHTransaction {
    let transactionHash: String
    let from: String
    let to: String
    let amount: String
    let date: Date
    let data: Data?
    let token: ERC20Token? // nil if it is custom ETH transaction
    let networkId: Int64
    var isPending = false
    
    public init(tx: ETHTransaction) {
        self.transactionHash = tx.transactionHash
        self.from = tx.from
        self.to = tx.to
        self.amount = tx.amount
        self.date = tx.date
        self.data = tx.data
        self.token = tx.token
        self.networkId = tx.networkId
        self.isPending = tx.isPending
    }
    
    public init(transactionHash: String,
                from: String,
                to: String,
                amount: String,
                date: Date,
                data: Data?,
                token: ERC20Token?,
                networkId: Int64,
                isPending: Bool) {
        self.transactionHash = transactionHash
        self.from = from
        self.to = to
        self.amount = amount
        self.date = date
        self.data = data
        self.token = token
        self.networkId = networkId
        self.isPending = isPending
    }
}

extension ETHTransaction: Equatable {
    public static func ==(lhs: ETHTransaction, rhs: ETHTransaction) -> Bool {
        return lhs.transactionHash == rhs.transactionHash
    }
}

public struct WriteTransactionInfo {
    var contractAddress: String
    var writeTransaction: WriteTransaction
    var methodName: String
}

public struct ReadTransactionInfo {
    var contractAddress: String
    var readTransaction: ReadTransaction
    var methodName: String
}

public enum TransactionType {
    case custom
    case arbitraryMethodWithParams
}
