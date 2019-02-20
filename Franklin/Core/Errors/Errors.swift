//
//  CommonErrors.swift
//  DiveLane
//
//  Created by Anton Grigorev on 29/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public struct Errors {
    
    public enum JS: Error {
        case wrongContext
        case noObject
        case wrongJson
        case wrongData
    }
    
    public enum CommonErrors: Error {
        case wrongAddress
        case wrongKeystore
        case unknownError
        case wrongType
    }
    
    public enum WalletErrors: Error {
        case noPlasmaID
        case wrongWallet
        case cantImportWallet
        case cantDeleteWallet
        case cantCreateWallet
        case noSelectedWallet
        case cantSelectWallet
        case cantGetWallet
        case unknownError
        case cantAddToken
        case noSelectedToken
        case cantDeleteToken
        case cantSaveTx
        case cantGetTx
    }
    
    public enum ContactErrors: Error {
        case cantCreateContact
        case cantGetContact
        case wrongContact
        case cantDeleteContact
    }
    
    public enum TokenErrors: Error {
        case cantCreateToken
        case wrongToken
        case cantDeleteToken
        case cantGetToken
        case cantSaveToken
    }
    
    public enum TransactionErrors: Error {
        case cantCreateTransaction
        case cantGetTransaction
    }
    
    public enum NetworkStorageErrors: Error {
        case cantCreateNetwork
        case cantSelectNetwork
        case cantGetNetwork
    }
    
    public enum NetworkErrors: Error {
        case wrongURL
        case wrongJSON
        case noSuchAPIOnTheEtherscan
        case noData
        case cantCreateRequest
    }
}
