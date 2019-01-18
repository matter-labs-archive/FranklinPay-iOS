//
//  PlasmaCode.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 08/12/2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress
import EthereumABI
import Web3swift

/// A Plasma Code that contains all necessary information
public struct PlasmaCode {
    /// Additional Plasma parameter
    public struct PlasmaParameter {
        public var type: ABI.Element.ParameterType
        public var value: AnyObject
    }
    /// Plasma Transaction type
    public var txType: PlasmaTransaction.TransactionType
    /// Target address
    public var targetAddress: EthereumAddress
    /// Network chainID
    public var chainID: BigUInt?
    /// Plasma Transaction amount
    public var amount: String?
    
    /// Creates PlasmaCode object
    ///
    /// - Parameters:
    ///   - targetAddress: target address
    ///   - numberOfTxInBlock: Plasma transaction type
    public init(_ targetAddress: EthereumAddress, txType: PlasmaTransaction.TransactionType = .split) {
        self.txType = txType
        self.targetAddress = targetAddress
    }
}
