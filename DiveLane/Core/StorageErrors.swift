//
//  StorageErrors.swift
//  DiveLane
//
//  Created by Anton Grigorev on 27/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

extension Errors {
    public enum StorageErrors: Error {
        case wrongWallet
        case cantImportWallet
        case cantDeleteWallet
        case cantCreateWallet
        case noSelectedWallet
        case cantSelectWallet
        case unknownError
        case cantCreateContact
        case cantGetContact
        case wrongContact
        case entityInsert
        case cantDeleteContact
        case cantCreateToken
        case wrongToken
        case cantDeleteToken
        case cantGetToken
        case cantCreateTransaction
        case cantGetTransaction
        case cantCreateNetwork
        case cantSelectNetwork
    }
}
