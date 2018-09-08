//
//  TransactionsService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import BigInt

protocol TransactionsService {
    
    func prepareTransactionToContract(data: [Any],
                                      contractAbi: String,
                                      contractAddress: String,
                                      method: String,
                                      amountString: String,
                                      gasLimit: BigUInt,
                                      completion: @escaping (Result<TransactionIntermediate>) -> Void)
    
    func prepareTransactionForSendingEther(destinationAddressString: String,
                                           amountString: String,
                                           gasLimit: BigUInt,
                                           completion: @escaping (Result<TransactionIntermediate>) -> Void)
    
    func prepareTransactionForSendingERC(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: BigUInt,
                                      tokenAddress token: String,
                                      completion: @escaping (Result<TransactionIntermediate>) -> Void)
    
    func sendToContract(transaction: TransactionIntermediate,
                      with password: String,
                      options: Web3Options?,
                      completion: @escaping (Result<TransactionSendingResult>) -> Void)
    
    func sendToken(transaction: TransactionIntermediate,
                   with password: String,
                   options: Web3Options?,
                   completion: @escaping (Result<TransactionSendingResult>) -> Void)
    
    
    func contract(for address: String, web3: web3) -> web3.web3contract?
}

enum SendEthErrors: Error {
    case invalidDestinationAddress
    case invalidAmountFormat
    case createTransactionIssue
    case retrievingEstimatedGasError
    case retrievingGasPriceError
    case emptyResult
    case noAvailableKeys
    case contractLoadingError
}
