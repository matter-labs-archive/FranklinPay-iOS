//
//  ReadTransactionInfo.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift

public struct ReadTransactionInfo {
    var contractAddress: String
    var readTransaction: ReadTransaction
    var methodName: String
}
