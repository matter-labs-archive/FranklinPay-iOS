//
//  Input.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

/// An RLP encoded set that describes input in Transaction
public struct TransactionInput {
    public var blockNumber: BigUInt
    public var txNumberInBlock: BigUInt
    public var outputNumberInTx: BigUInt
    public var amount: BigUInt
    
    /// Returns serialized TransactionInput
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    /// Creates TransactionInput object
    ///
    /// - Parameters:
    ///   - blockNumber: the number of block that stores transaction
    ///   - txNumberInBlock: the number of PlasmaTransaction in block
    ///   - outputNumberInTx: output number in transaction
    ///   - amount: "Amount" field, that is more a data field, usually used for an amount of the output referenced by previous field, but has special meaning for "Deposit" transactions
    /// - Throws: `PlasmaErrors.StructureErrors.wrongBitWidth` if bytes count in some parameter is wrong
    public init(blockNumber: BigUInt, txNumberInBlock: BigUInt, outputNumberInTx: BigUInt, amount: BigUInt) throws {

        guard blockNumber.bitWidth <= blockNumberMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard txNumberInBlock.bitWidth <= txNumberInBlockMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard outputNumberInTx.bitWidth <= outputNumberInTxMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard amount.bitWidth <= amountMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}

        self.blockNumber = blockNumber
        self.txNumberInBlock = txNumberInBlock
        self.outputNumberInTx = outputNumberInTx
        self.amount = amount
    }

    /// Creates TransactionInput object
    ///
    /// - Parameters:
    ///   - data: encoded Data of TransactionInput
    /// - Throws: throws various `PlasmaErrors.StructureErrors` if decoding is wrong or decoded data is wrong in some way
    public init(data: Data) throws {

        guard let dataDecoded = RLP.decode(data) else {throw PlasmaErrors.StructureErrors.cantDecodeData}
        guard dataDecoded.isList else {throw PlasmaErrors.StructureErrors.isNotList}
        guard let count = dataDecoded.count else {throw PlasmaErrors.StructureErrors.wrongDataCount}
        let dataArray: RLP.RLPItem
        guard let firstItem = dataDecoded[0] else {throw PlasmaErrors.StructureErrors.dataIsNotArray}
        if count > 1 {
            dataArray = dataDecoded
        } else {
            dataArray = firstItem
        }
        guard dataArray.count == 4 else {throw PlasmaErrors.StructureErrors.wrongDataCount}
        guard let blockNumberData = dataArray[0]?.data else {throw PlasmaErrors.StructureErrors.isNotData}
        guard let txNumberInBlockData = dataArray[1]?.data else {throw PlasmaErrors.StructureErrors.isNotData}
        guard let outputNumberInTxData = dataArray[2]?.data else {throw PlasmaErrors.StructureErrors.isNotData}
        guard let amountData = dataArray[3]?.data else {throw PlasmaErrors.StructureErrors.isNotData}

        let blockNumber = BigUInt(blockNumberData)
        let txNumberInBlock = BigUInt(txNumberInBlockData)
        let outputNumberInTx = BigUInt(outputNumberInTxData)
        let amount = BigUInt(amountData)

        guard blockNumber.bitWidth <= blockNumberMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard txNumberInBlock.bitWidth <= txNumberInBlockMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard outputNumberInTx.bitWidth <= outputNumberInTxMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard amount.bitWidth <= amountMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}

        self.blockNumber = blockNumber
        self.txNumberInBlock = txNumberInBlock
        self.outputNumberInTx = outputNumberInTx
        self.amount = amount
    }

    /// Serializes TransactionInput
    ///
    /// - Returns: encoded AnyObject array consisted of TransactionInput items
    /// - Throws: `PlasmaErrors.StructureErrors.cantEncodeData` if data can't be encoded
    public func serialize() throws -> Data {
        let dataArray = self.prepareForRLP()
        guard let encoded = RLP.encode(dataArray) else {throw PlasmaErrors.StructureErrors.cantEncodeData}
        return encoded
    }

    /// Plases TransactionInput items in AnyObject array
    ///
    /// - Returns: AnyObject array of TransactionInput items in Data type
    public func prepareForRLP() -> [AnyObject] {
        let blockNumberData = self.blockNumber.serialize().setLengthLeft(blockNumberByteLength)!
        let txNumberData = self.txNumberInBlock.serialize().setLengthLeft(txNumberInBlockByteLength)!
        let outputNumberData = self.outputNumberInTx.serialize().setLengthLeft(outputNumberInTxByteLength)
        let amountData = self.amount.serialize().setLengthLeft(amountByteLength)
        let dataArray = [blockNumberData, txNumberData, outputNumberData, amountData] as [AnyObject]
        return dataArray
    }
}

extension TransactionInput: Equatable {
    public static func ==(lhs: TransactionInput, rhs: TransactionInput) -> Bool {
        return lhs.blockNumber == rhs.blockNumber &&
            lhs.txNumberInBlock == rhs.txNumberInBlock &&
            lhs.outputNumberInTx == rhs.outputNumberInTx &&
            lhs.amount == rhs.amount &&
            lhs.data == rhs.data
    }
}
