//
//  SignedTransaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import struct BigInt.BigUInt
import secp256k1_swift
import EthereumAddress

/// An RLP encoded set that describes signed Transaction. Signature is based on EthereumPersonalHash(RLPEncode(Transaction))
public struct SignedTransaction {

    private let helpers = TransactionHelpers()

    public var transaction: Transaction
    public var v: BigUInt
    public var r: Data
    public var s: Data
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    /// returns EthereumAddress of transaction sender
    public var sender: EthereumAddress {
        do {
            return try self.recoverSender()
        } catch {
            return EthereumAddress("")!
        }
    }

    public init() {
        self.transaction = Transaction()
        self.v = BigUInt(0)
        self.r = Data(repeating: 0, count: Int(rByteLength))
        self.s = Data(repeating: 0, count: Int(sByteLength))
    }

    /// Creates SignedTransaction object that implement signed transaction in Plasma
    ///
    /// - Parameters:
    ///   - transaction: unsigned transaction RLP encoded set
    ///   - v: the recovery id
    ///   - r: output of the signature
    ///   - s: output of the signature
    /// - Throws: `StructureErrors.wrongBitWidth` if bytes count in some parameter is wrong
    public init(transaction: Transaction, v: BigUInt, r: Data, s: Data) throws {
        guard v.bitWidth <= vMaxWidth else {throw StructureErrors.wrongBitWidth}
        guard r.count <= rByteLength else {throw StructureErrors.wrongBitWidth}
        guard s.count <= sByteLength else {throw StructureErrors.wrongBitWidth}

        guard v == 27 || v == 28 else {throw StructureErrors.wrongData}

        self.transaction = transaction
        self.v = v
        self.r = r
        self.s = s
    }

    /// Creates SignedTransaction object that implement signed transaction in Plasma
    ///
    /// - Parameter data: encoded Data of SignedTransaction
    /// - Throws: throws various `StructureErrors` if decoding is wrong or decoded data is wrong in some way
    public init(data: Data) throws {
        guard let item = RLP.decode(data) else {throw StructureErrors.cantDecodeData}
        guard let dataArray = item[0] else {throw StructureErrors.dataIsNotArray}
        
        guard dataArray.isList else {throw StructureErrors.isNotList}
        guard dataArray.count == 4 else {throw StructureErrors.wrongDataCount}
        guard let transactionData = dataArray[0]?.data else {throw StructureErrors.isNotData}
        guard let vData = dataArray[1]?.data else {throw StructureErrors.isNotData}
        guard let rData = dataArray[2]?.data else {throw StructureErrors.isNotData}
        guard let sData = dataArray[3]?.data else {throw StructureErrors.isNotData}

        let v = BigUInt(vData)
        guard v.bitWidth <= vMaxWidth else {throw StructureErrors.wrongBitWidth}

        guard rData.count <= rByteLength else {throw StructureErrors.wrongBitWidth}
        guard sData.count <= sByteLength else {throw StructureErrors.wrongBitWidth}

        guard let transaction = try? Transaction.init(data: transactionData) else {throw StructureErrors.wrongData}

        self.v = v
        self.r = rData
        self.s = sData
        self.transaction = transaction
    }

    /// Plases SignedTransaction items in AnyObject array
    ///
    /// - Returns: AnyObject array of SignedTransaction items in Data type
    public func prepareForRLP() -> [AnyObject] {
        let vData = self.v.serialize().setLengthLeft(vByteLength)!
        let transactionObject = self.transaction.prepareForRLP()
        let dataArray = [transactionObject, vData, self.r, self.s] as [AnyObject]
        return dataArray
    }

    /// Serializes SignedTransaction
    ///
    /// - Returns: encoded AnyObject array consisted of SignedTransaction items
    /// - Throws: `StructureErrors.cantEncodeData` if data can't be encoded
    public func serialize() throws -> Data {
        let dataArray = self.prepareForRLP()
        guard let encoded = RLP.encode(dataArray) else {throw StructureErrors.cantEncodeData}
        return encoded
    }

    /// Deduces a sender from transaction signature
    ///
    /// - Returns: sender EthereumAddress
    /// - Throws: `StructureErrors.wrongData` if signature is wrong or `StructureErrors.wrongAddress` if address is wrong
    public func recoverSender() throws -> EthereumAddress {
        guard let hash = try? TransactionHelpers.hashForSignature(data: self.transaction.data) else {throw StructureErrors.wrongData}
        var v = self.v
        if v > 3 {
            v -= BigUInt(27)
        }
        let vData = v.serialize().setLengthLeft(vByteLength)!
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: self.r, s: self.s) else {throw StructureErrors.wrongData}
        guard let signerPubKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {throw StructureErrors.wrongData}
        guard let addressData = try? TransactionHelpers.publicToAddressData(signerPubKey) else {throw StructureErrors.wrongAddress}
        guard let address = EthereumAddress(addressData) else {throw StructureErrors.wrongAddress}
        return address
    }
}

extension SignedTransaction: Equatable {
    public static func ==(lhs: SignedTransaction, rhs: SignedTransaction) -> Bool {
        return lhs.transaction == rhs.transaction &&
            lhs.v == rhs.v &&
            lhs.r == rhs.r &&
            lhs.s == rhs.s
    }
}
