//
//  PlasmaContractMethods.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 08.11.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation

/// Preset of Plasma Contract methods
///
/// - deposit: funds deposition on Plasma Contract
/// - withdrawCollateral: returns a value wich is used as value in startExit method
/// - startExit: starts exiting procedure for some UTXO
public enum PlasmaContractMethod: String {
    case deposit = "deposit"
    case withdrawCollateral = "WithdrawCollateral"
    case startExit = "startExit"
}
