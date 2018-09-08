//
//  Web3Service.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import BigInt

protocol IWeb3SwiftService {
    func sendTransaction(transaction: TransactionIntermediate, password: String, completion: @escaping (Result<TransactionSendingResult>) -> Void)
    func getETHbalance (completion: @escaping (String?,Error?) -> Void)
    func getERCBalance(for token: String,
                    address: String,
                    completion: @escaping (String?,Error?)->Void)
    func contract(for address: String) -> web3.web3contract?
    func defaultOptions() -> Web3Options
}

