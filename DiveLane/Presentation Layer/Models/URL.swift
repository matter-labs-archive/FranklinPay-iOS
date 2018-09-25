//
//  URL.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

import web3swift

struct GenericParsedURL {
    var type: TransactionType
    var recieverAddress: EthereumAddress?
    var tokenAddress: EthereumAddress?
    var methodName: String?
    var amount: UInt64?
    var parameters: [Any]?
    var parametersView: [Parameter]?
    var contractAbi: String?
}
