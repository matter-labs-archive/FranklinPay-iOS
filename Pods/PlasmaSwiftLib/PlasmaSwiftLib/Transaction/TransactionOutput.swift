//
//  Output.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt
import EthereumAddress

/// An RLP encoded set that describes output in Transaction
public struct TransactionOutput {

    let helpers = TransactionHelpers()

    public var outputNumberInTx: BigUInt
    public var receiverEthereumAddress: EthereumAddress
    public var amount: BigUInt
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    /// Creates TransactionOutput object that can be spent as an input in a new transaction
    ///
    /// - Parameters:
    ///   - outputNumberInTx: output number in this transaction
    ///   - receiverEthereumAddress: destionation ethereum address
    ///   - amount: "amount" field
    /// - Throws: `StructureErrors.wrongBitWidth` if bytes count in some parameter is wrong
    public init(outputNumberInTx: BigUInt, receiverEthereumAddress: EthereumAddress, amount: BigUInt) throws {
        guard outputNumberInTx.bitWidth <= outputNumberInTxMaxWidth else {throw StructureErrors.wrongBitWidth}
        guard receiverEthereumAddress.addressData.count <= receiverEthereumAddressByteLength else {throw StructureErrors.wrongBitWidth}
        guard amount.bitWidth <= amountMaxWidth else {throw StructureErrors.wrongBitWidth}

        self.outputNumberInTx = outputNumberInTx
        self.receiverEthereumAddress = receiverEthereumAddress
        self.amount = amount
    }

    /// Creates TransactionOutput object that can be spent as an input in a new transaction
    ///
    /// - Parameter data: encoded Data of TransactionOutput
    /// - Throws: throws various `StructureErrors` if decoding is wrong or decoded data is wrong in some way
    public init(data: Data) throws {

        guard let dataDecoded = RLP.decode(data) else {throw StructureErrors.cantDecodeData}
        guard dataDecoded.isList else {throw StructureErrors.isNotList}
        guard let count = dataDecoded.count else {throw StructureErrors.wrongDataCount}
        let dataArray: RLP.RLPItem
        guard let firstItem = dataDecoded[0] else {throw StructureErrors.dataIsNotArray}
        if count > 1 {
            dataArray = dataDecoded
        } else {
            dataArray = firstItem
        }
        guard dataArray.count == 3 else {throw StructureErrors.wrongDataCount}

        guard let outputNumberInTxData = dataArray[0]?.data else {throw StructureErrors.isNotData}
        guard let receiverEthereumAddressData = dataArray[1]?.data else {throw StructureErrors.isNotData}
        guard let amountData = dataArray[2]?.data else {throw StructureErrors.isNotData}

        let outputNumberInTx = BigUInt(outputNumberInTxData)
        guard let receiverEthereumAddress = EthereumAddress(receiverEthereumAddressData) else {throw StructureErrors.wrongData}
        let amount = BigUInt(amountData)

        guard outputNumberInTx.bitWidth <= outputNumberInTxMaxWidth else {throw StructureErrors.wrongBitWidth}
        guard receiverEthereumAddress.addressData.count <= receiverEthereumAddressByteLength else {throw StructureErrors.wrongDataCount}
        guard amount.bitWidth <= amountMaxWidth else {throw StructureErrors.wrongBitWidth}

        self.outputNumberInTx = outputNumberInTx
        self.receiverEthereumAddress = receiverEthereumAddress
        self.amount = amount
    }

    /// Serializes TransactionOutput
    ///
    /// - Returns: encoded AnyObject array consisted of TransactionOutput items
    /// - Throws: `StructureErrors.cantEncodeData` if data can't be encoded
    public func serialize() throws -> Data {
        let dataArray = self.prepareForRLP()
        guard let encoded = RLP.encode(dataArray) else {throw StructureErrors.cantEncodeData}
        return encoded
    }

    /// Plases TransactionOutput items in AnyObject array
    ///
    /// - Returns: AnyObject array of TransactionOutput items in Data type
    public func prepareForRLP() -> [AnyObject] {
        let outputNumberData = self.outputNumberInTx.serialize().setLengthLeft(outputNumberInTxByteLength)
        let addressData = self.receiverEthereumAddress.addressData
        let amountData = self.amount.serialize().setLengthLeft(amountByteLength)
        let dataArray = [outputNumberData, addressData, amountData] as [AnyObject]
        return dataArray
    }
}

extension TransactionOutput: Equatable {
    public static func ==(lhs: TransactionOutput, rhs: TransactionOutput) -> Bool {
        return lhs.outputNumberInTx == rhs.outputNumberInTx
            && lhs.receiverEthereumAddress.address == rhs.receiverEthereumAddress.address
            && lhs.amount == rhs.amount
            && lhs.data == rhs.data
    }
}
