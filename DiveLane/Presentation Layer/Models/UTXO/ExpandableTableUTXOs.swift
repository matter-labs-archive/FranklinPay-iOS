//
//  ExpandableTableUTXOs.swift
//  DiveLane
//
//  Created by Anton Grigorev on 27.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import PlasmaSwiftLib

struct ExpandableTableUTXOs {
    var isExpanded: Bool
    var utxos: [TableUTXO]
}

struct TableUTXO {
    let utxo: ListUTXOsModel
    let inWallet: KeyWalletModel
    var isSelected: Bool
}

extension TableUTXO: Equatable {
    static func ==(lhs: TableUTXO, rhs: TableUTXO) -> Bool {
        let equalUTXOs = lhs.utxo == rhs.utxo
        return equalUTXOs &&
            lhs.inWallet == rhs.inWallet
    }
}

extension ListUTXOsModel: Equatable {
    public static func ==(lhs: ListUTXOsModel, rhs: ListUTXOsModel) -> Bool {
        let equalUTXOs = lhs.blockNumber == rhs.blockNumber &&
            lhs.outputNumber == rhs.outputNumber &&
            lhs.transactionNumber == rhs.transactionNumber &&
            lhs.value == rhs.value
        return equalUTXOs
    }
}
