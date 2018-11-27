//
//  Transaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt
import secp256k1_swift

/// An RLP encoded set that describes unsigned Transaction
public class Transaction {
    /// The type of transaction can be:
    ///     - null
    ///     - fund
    ///     - split - use to send funds
    ///     - merge - use to merge UTXOs
    public enum TransactionType {
        case null
        case fund
        case split
        case merge

        public var data: Data {
            switch self {
            case .null:
                return Data([UInt8(0)])
            case .split:
                return Data([UInt8(1)])
            case .merge:
                return Data([UInt8(2)])
            case .fund:
                return Data([UInt8(4)])
            }
        }

        public init?(byte: UInt8) {
            if byte == 0 {
                self = .null
                return
            } else if byte == 1 {
                self = .split
                return
            } else if byte == 2 {
                self = .merge
                return
            } else if byte == 4 {
                self = .fund
                return
            }
            return nil
        }

    }

    public var txType: TransactionType
    public var inputs: [TransactionInput]
    public var outputs: [TransactionOutput]
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    public init() {
        self.txType = .null
        self.inputs = [TransactionInput]()
        self.outputs = [TransactionOutput]()
    }

    /// Creates Transaction object that implement unsigned transaction in Plasma
    ///
    /// - Parameters:
    ///   - txType: describes the purpose of transaction and can be:
    ///     - null
    ///     - fund
    ///     - split - use to send funds
    ///     - merge - use to merge UTXOs
    ///   - inputs: an array of TransactionInput, maximum 2 items
    ///   - outputs: an array of TransactionOutput, maximum 3 items. One of the outputs is an explicit output to an address of Plasma operator
    /// - Throws: `StructureErrors.wrongBitWidth` if bytes count in some parameter is wrong
    public init(txType: TransactionType, inputs: [TransactionInput], outputs: [TransactionOutput]) throws {
        guard inputs.count <= inputsArrayMax else {throw StructureErrors.wrongBitWidth}
        guard outputs.count <= outputsArrayMax else {throw StructureErrors.wrongBitWidth}

        self.txType = txType
        self.inputs = inputs
        self.outputs = outputs
    }

    /// Creates Transaction object that implement unsigned transaction in Plasma
    ///
    /// - Parameter data: encoded Data of Transaction
    /// - Throws: throws various `StructureErrors` if decoding is wrong or decoded data is wrong in some way
    public init(data: Data) throws {

        guard let item = RLP.decode(data) else {throw StructureErrors.cantDecodeData}
        guard item.isList else {throw StructureErrors.isNotList}
        guard let count = item.count else {throw StructureErrors.wrongDataCount}
        let dataArray: RLP.RLPItem

        guard let firstItem = item[0] else {throw StructureErrors.dataIsNotArray}
        if count > 1 {
            dataArray = item
        } else {
            dataArray = firstItem
        }

        guard dataArray.count == 3 else {throw StructureErrors.wrongDataCount}

        guard let txTypeData = dataArray[0]?.data else {throw StructureErrors.isNotData}
        guard let inputsData = dataArray[1] else {throw StructureErrors.wrongDataCount}
        guard let outputsData = dataArray[2] else {throw StructureErrors.wrongDataCount}

        guard txTypeData.count == txTypeByteLength else {throw StructureErrors.wrongBitWidth}
        guard let txType = TransactionType(byte: txTypeData.first!) else {throw StructureErrors.wrongData}
        self.txType = txType

        var inputs = [TransactionInput]()
        if inputsData.isList {
            inputs.reserveCapacity(inputsData.count!)
            for inputIndex in 0 ..< inputsData.count! {
                guard let inputData = inputsData[inputIndex]!.data else {throw StructureErrors.isNotData}
                guard let input = try? TransactionInput(data: inputData) else {throw StructureErrors.wrongData}
                inputs.append(input)
            }
        }

        var outputs = [TransactionOutput]()
        if outputsData.isList {
            outputs.reserveCapacity(outputsData.count!)
            for outputIndex in 0 ..< outputsData.count! {
                guard let outputData = outputsData[outputIndex]!.data else {throw StructureErrors.isNotData}
                guard let output = try? TransactionOutput(data: outputData) else {throw StructureErrors.wrongData}
                outputs.append(output)
            }
        }

        self.inputs = inputs
        self.outputs = outputs
    }

    /// Performes signing of transaction
    ///
    /// - Parameters:
    ///   - privateKey: private key used to sign transaction
    ///   - useExtraEntropy: setups additional entropy for good quality randomness
    /// - Returns: SignedTransaction object that can be used to send in Plasma
    /// - Throws: `StructureErrors.wrongData` if private key, transaction or something in signing process is wrong
    public func sign(privateKey: Data, useExtraEntropy: Bool = false) throws -> SignedTransaction {
        for _ in 0..<1024 {
            do {
                if let signature = try? signature(privateKey: privateKey, useExtraEntropy: useExtraEntropy) {
                    var v = BigUInt(signature.v)
                    if (v < 27) {
                        v += BigUInt(27)
                    }
                    let r = signature.r
                    let s = signature.s
                    if let signedTransaction = try? SignedTransaction(transaction: self,
                                                                      v: v,
                                                                      r: r,
                                                                      s: s) {return signedTransaction}
                }
            }
        }
        throw StructureErrors.wrongData
    }

    private func signature(privateKey: Data, useExtraEntropy: Bool = false) throws -> SECP256K1.UnmarshaledSignature {
        guard let hash = try? TransactionHelpers.hashForSignature(data: self.data) else {throw StructureErrors.wrongData}
        let signature = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        guard let serializedSignature = signature.serializedSignature else {throw StructureErrors.wrongData}
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else {throw StructureErrors.wrongData}
        return unmarshalledSignature
    }

    /// Plases Transaction items in AnyObject array
    ///
    /// - Returns: AnyObject array of Transaction items in Data type
    public func prepareForRLP() -> [AnyObject] {
        let txTypeData = self.txType.data
        var inputsData = [[AnyObject]]()
        inputsData.reserveCapacity(self.inputs.count)
        for input in self.inputs {
            inputsData.append(input.prepareForRLP())
        }
        var outputsData = [[AnyObject]]()
        outputsData.reserveCapacity(self.outputs.count)
        for output in self.outputs {
            outputsData.append(output.prepareForRLP())
        }
        let totalData = [txTypeData, inputsData, outputsData] as [AnyObject]
        return totalData
    }

    /// Serializes Transaction
    ///
    /// - Returns: encoded AnyObject array consisted of Transaction items
    /// - Throws: `StructureErrors.cantEncodeData` if data can't be encoded
    public func serialize() throws -> Data {
        let dataArray = self.prepareForRLP()
        guard let encoded = RLP.encode(dataArray) else {throw StructureErrors.cantEncodeData}
        return encoded
    }
}

extension Transaction: Equatable {
    public static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.txType == rhs.txType &&
            lhs.inputs == rhs.inputs &&
            lhs.outputs == rhs.outputs &&
            lhs.data == rhs.data
    }
}
