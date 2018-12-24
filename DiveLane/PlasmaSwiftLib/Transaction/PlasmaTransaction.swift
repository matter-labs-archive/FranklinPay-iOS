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
public class PlasmaTransaction {
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

        /// Data representation of transaction type
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

        /// Byte representation of transaction type
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
    
    /// Returns serialized unsigned Transaction
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    /// Null type Transaction init
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
    /// - Throws: `PlasmaErrors.StructureErrors.wrongBitWidth` if bytes count in some parameter is wrong
    public init(txType: TransactionType, inputs: [TransactionInput], outputs: [TransactionOutput]) throws {
        guard inputs.count <= inputsArrayMax else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard outputs.count <= outputsArrayMax else {throw PlasmaErrors.StructureErrors.wrongBitWidth}

        self.txType = txType
        self.inputs = inputs
        self.outputs = outputs
    }

    /// Creates Transaction object that implement unsigned transaction in Plasma
    ///
    /// - Parameter data: encoded Data of Transaction
    /// - Throws: throws various `PlasmaErrors.StructureErrors` if decoding is wrong or decoded data is wrong in some way
    public init(data: Data) throws {

        guard let item = RLP.decode(data) else {throw PlasmaErrors.StructureErrors.cantDecodeData}
        guard item.isList else {throw PlasmaErrors.StructureErrors.isNotList}
        guard let count = item.count else {throw PlasmaErrors.StructureErrors.wrongDataCount}
        let dataArray: RLP.RLPItem

        guard let firstItem = item[0] else {throw PlasmaErrors.StructureErrors.dataIsNotArray}
        if count > 1 {
            dataArray = item
        } else {
            dataArray = firstItem
        }

        guard dataArray.count == 3 else {throw PlasmaErrors.StructureErrors.wrongDataCount}

        guard let txTypeData = dataArray[0]?.data else {throw PlasmaErrors.StructureErrors.isNotData}
        guard let inputsData = dataArray[1] else {throw PlasmaErrors.StructureErrors.wrongDataCount}
        guard let outputsData = dataArray[2] else {throw PlasmaErrors.StructureErrors.wrongDataCount}

        guard txTypeData.count == txTypeByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard let txType = TransactionType(byte: txTypeData.first!) else {throw PlasmaErrors.StructureErrors.wrongData}
        self.txType = txType

        var inputs = [TransactionInput]()
        if inputsData.isList {
            inputs.reserveCapacity(inputsData.count!)
            for inputIndex in 0 ..< inputsData.count! {
                guard let inputData = inputsData[inputIndex]!.data else {throw PlasmaErrors.StructureErrors.isNotData}
                guard let input = try? TransactionInput(data: inputData) else {throw PlasmaErrors.StructureErrors.wrongData}
                inputs.append(input)
            }
        }

        var outputs = [TransactionOutput]()
        if outputsData.isList {
            outputs.reserveCapacity(outputsData.count!)
            for outputIndex in 0 ..< outputsData.count! {
                guard let outputData = outputsData[outputIndex]!.data else {throw PlasmaErrors.StructureErrors.isNotData}
                guard let output = try? TransactionOutput(data: outputData) else {throw PlasmaErrors.StructureErrors.wrongData}
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
    /// - Throws: `PlasmaErrors.StructureErrors.wrongData` if private key, transaction or something in signing process is wrong
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
        throw PlasmaErrors.StructureErrors.wrongData
    }

    private func signature(privateKey: Data, useExtraEntropy: Bool = false) throws -> SECP256K1.UnmarshaledSignature {
        guard let hash = try? TransactionHelpers.hashForSignature(data: self.data) else {throw PlasmaErrors.StructureErrors.wrongData}
        let signature = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        guard let serializedSignature = signature.serializedSignature else {throw PlasmaErrors.StructureErrors.wrongData}
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else {throw PlasmaErrors.StructureErrors.wrongData}
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
    /// - Throws: `PlasmaErrors.StructureErrors.cantEncodeData` if data can't be encoded
    public func serialize() throws -> Data {
        let dataArray = self.prepareForRLP()
        guard let encoded = RLP.encode(dataArray) else {throw PlasmaErrors.StructureErrors.cantEncodeData}
        return encoded
    }
}

extension PlasmaTransaction: Equatable {
    public static func ==(lhs: PlasmaTransaction, rhs: PlasmaTransaction) -> Bool {
        return lhs.txType == rhs.txType &&
            lhs.inputs == rhs.inputs &&
            lhs.outputs == rhs.outputs &&
            lhs.data == rhs.data
    }
}
