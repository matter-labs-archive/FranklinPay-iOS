//
//  listUTXOs.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt

/// A Plasma UTXO implementation and its convenient methods
public final class PlasmaUTXOs {
    public var blockNumber: BigUInt
    public var transactionNumber: BigUInt
    public var outputNumber: BigUInt
    public var value: BigUInt

    /// Init Plasma UTXO from json
    ///
    /// - Parameter json: JSON structure with following keys:
    ///    1. blockNumber - integer number of Block;
    ///    2. transactionNumber - integer number of Transaction in Block;
    ///    3. outputNumber - output number in Transaction;
    ///    4. value - amount of Ether in UTXO.
    /// - Throws: `StructureErrors.wrongData` if json is wrong.
    public init(json: [String: Any]) throws {
        guard let blockNumber = json["blockNumber"] as? Int else {throw PlasmaErrors.StructureErrors.wrongData}
        guard let transactionNumber = json["transactionNumber"] as? Int else {throw PlasmaErrors.StructureErrors.wrongData}
        guard let outputNumber = json["outputNumber"] as? Int else {throw PlasmaErrors.StructureErrors.wrongData}
        guard let value = json["value"] as? String else {throw PlasmaErrors.StructureErrors.wrongData}

        guard let bigUIntValue = BigUInt(value) else {throw PlasmaErrors.StructureErrors.wrongData}

        self.blockNumber = BigUInt(blockNumber)
        self.transactionNumber = BigUInt(transactionNumber)
        self.outputNumber = BigUInt(outputNumber)
        self.value = bigUIntValue
    }

    /// Form Transaction Input from this UTXO
    ///
    /// - Returns: TransactionInput that is used in building Plasma Transaction
    /// - Throws: `StructureErrors.wrongBitWidth` if bytes count in some parameter is wrong
    public func toTransactionInput() throws -> TransactionInput {
        return try TransactionInput(blockNumber: self.blockNumber, txNumberInBlock: self.transactionNumber, outputNumberInTx: self.outputNumber, amount: self.value)
    }
}

extension PlasmaUTXOs: Equatable {
    public static func ==(lhs: PlasmaUTXOs, rhs: PlasmaUTXOs) -> Bool {
        let equalUTXOs = lhs.blockNumber == rhs.blockNumber &&
            lhs.outputNumber == rhs.outputNumber &&
            lhs.transactionNumber == rhs.transactionNumber &&
            lhs.value == rhs.value
        return equalUTXOs
    }
}
