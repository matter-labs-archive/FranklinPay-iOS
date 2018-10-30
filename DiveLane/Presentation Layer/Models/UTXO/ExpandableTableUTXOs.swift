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
        let equalUTXOs = lhs.utxo.blockNumber == rhs.utxo.blockNumber &&
            lhs.utxo.outputNumber == rhs.utxo.outputNumber &&
            lhs.utxo.transactionNumber == rhs.utxo.transactionNumber &&
            lhs.utxo.value == rhs.utxo.value
        return equalUTXOs &&
            lhs.inWallet == rhs.inWallet
    }
}
