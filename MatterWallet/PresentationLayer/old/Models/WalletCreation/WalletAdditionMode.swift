//
//  WalletAdditionMode.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

enum WalletAdditionMode {

    case importWallet
    case createWallet

    func title() -> String {
        switch self {
        case .importWallet:
            return "Import wallet"
        case .createWallet:
            return "Create wallet"
        }
    }
}
