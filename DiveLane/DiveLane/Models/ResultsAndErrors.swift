//
//  Result.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Error(Error)
}

enum WalletSavingError: Error {
    case couldNotSaveTheWallet
    case couldNotCreateTheWallet
    case couldNotGetTheWallet
    case couldNotGetAddress
    case couldNotGetThePrivateKey
}

enum SendErrors: Error {
    case invalidDestinationAddress
    case invalidAmountFormat
    case createTransactionIssue
    case retrievingEstimatedGasError
    case retrievingGasPriceError
    case emptyResult
    case noAvailableKeys
    case contractLoadingError
}

enum BalanceError: Error {
    case cantGetBalance
    case wrongBalance
    case wrongAddress
}
