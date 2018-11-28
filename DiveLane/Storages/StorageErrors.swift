//
//  StorageErrors.swift
//  DiveLane
//
//  Created by Anton Grigorev on 27/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

enum StorageErrors: Error {
    case noSuchWalletInStorage
    case cantImportWallet
    case cantDeleteWallet
    case cantCreateWallet
    case noSelectedWallet
    case cantSelectWallet
    case unknownError
    case cantCreateContact
    case cantGetContact
    case noSuchContactInStorage
    case cantDeleteContact
    case cantCreateToken
    case noSuchTokenInStorage
    case cantDeleteToken
    case cantGetToke
}
