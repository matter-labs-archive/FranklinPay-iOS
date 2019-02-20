//
//  WriteTranscationInfo.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift

public struct WriteTransactionInfo {
    var contractAddress: String
    var writeTransaction: WriteTransaction
    var methodName: String
}
