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
    let utxo: PlasmaUTXOs
    let inWallet: WalletModel
    var isSelected: Bool
}

extension TableUTXO: Equatable {
    static func ==(lhs: TableUTXO, rhs: TableUTXO) -> Bool {
        let equalUTXOs = lhs.utxo == rhs.utxo
        return equalUTXOs &&
            lhs.inWallet == rhs.inWallet
    }
}
