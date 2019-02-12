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
    
    /// Plasma network
    public var network: String
    /// Cheque number
    public var chequeNumber: String
    /// From address
    public var address: EthereumAddress
    /// Amount cheque
    public var amount: String
    
    /// Creates PlasmaCode object
    ///
    /// - Parameters:
    ///   - network: plasma network
    ///   - chequeNumber = cheque number
    public init(network: String, chequeNumber: String, address: EthereumAddress, amount: String) {
        self.network = network
        self.chequeNumber = chequeNumber
        self.address = address
        self.amount = amount
    }
}
