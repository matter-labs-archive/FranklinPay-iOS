//
//  GenericParsedURL.swift
//  DiveLane
//
//  Created by Антон Григорьев on 28/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress
import Web3swift

public struct GenericParsedURL {
    var type: TransactionType
    var recieverAddress: EthereumAddress?
    var tokenAddress: EthereumAddress?
    var methodName: String?
    var amount: UInt64?
    var parameters: [Any]?
    var parametersView: [Parameter]?
    var contractAbi: String?
}
