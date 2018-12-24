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

    public var transaction: PlasmaTransaction
    public var v: BigUInt
    public var r: Data
    public var s: Data
    
    /// Returns serialized SignedTransaction
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    /// Returns EthereumAddress of SignedTransaction sender
    public var sender: EthereumAddress {
        do {
            return try self.recoverSender()
        } catch {
            return EthereumAddress("")!
        }
    }

    /// SignedTransaction with null type PlasmaTransaction init
    public init() {
        self.transaction = PlasmaTransaction()
        self.v = BigUInt(0)
        self.r = Data(repeating: 0, count: Int(rByteLength))
        self.s = Data(repeating: 0, count: Int(sByteLength))
    }

    /// Creates SignedTransaction object that implement signed PlasmaTransaction in Plasma
    ///
    /// - Parameters:
    ///   - transaction: unsigned PlasmaTransaction RLP encoded set
    ///   - v: the recovery id
    ///   - r: output of the signature
    ///   - s: output of the signature
    /// - Throws: `PlasmaErrors.StructureErrors.wrongBitWidth` if bytes count in some parameter is wrong
    public init(transaction: PlasmaTransaction, v: BigUInt, r: Data, s: Data) throws {
        guard v.bitWidth <= vMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard r.count <= rByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard s.count <= sByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}

        guard v == 27 || v == 28 else {throw PlasmaErrors.StructureErrors.wrongData}

        self.transaction = transaction
        self.v = v
        self.r = r
        self.s = s
    }

    /// Creates SignedTransaction object that implement signed PlasmaTransaction in Plasma
    ///
    /// - Parameter data: encoded Data of SignedTransaction
    /// - Throws: throws various `PlasmaErrors.StructureErrors` if decoding is wrong or decoded data is wrong in some way
    public init(data: Data) throws {
        guard let item = RLP.decode(data) else {throw PlasmaErrors.StructureErrors.cantDecodeData}
        guard let dataArray = item[0] else {throw PlasmaErrors.StructureErrors.dataIsNotArray}
        
        guard dataArray.isList else {throw PlasmaErrors.StructureErrors.isNotList}
        guard dataArray.count == 4 else {throw PlasmaErrors.StructureErrors.wrongDataCount}
        guard let transactionData = dataArray[0]?.data else {throw PlasmaErrors.StructureErrors.isNotData}
        guard let vData = dataArray[1]?.data else {throw PlasmaErrors.StructureErrors.isNotData}
        guard let rData = dataArray[2]?.data else {throw PlasmaErrors.StructureErrors.isNotData}
        guard let sData = dataArray[3]?.data else {throw PlasmaErrors.StructureErrors.isNotData}

        let v = BigUInt(vData)
        guard v.bitWidth <= vMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}

        guard rData.count <= rByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard sData.count <= sByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}

        guard let transaction = try? PlasmaTransaction.init(data: transactionData) else {throw PlasmaErrors.StructureErrors.wrongData}

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
    /// - Throws: `PlasmaErrors.StructureErrors.cantEncodeData` if data can't be encoded
    public func serialize() throws -> Data {
        let dataArray = self.prepareForRLP()
        guard let encoded = RLP.encode(dataArray) else {throw PlasmaErrors.StructureErrors.cantEncodeData}
        return encoded
    }

    /// Deduces a sender from PlasmaTransaction signature
    ///
    /// - Returns: sender EthereumAddress
    /// - Throws: `PlasmaErrors.StructureErrors.wrongData` if signature is wrong or `PlasmaErrors.StructureErrors.wrongAddress` if address is wrong
    public func recoverSender() throws -> EthereumAddress {
        guard let hash = try? TransactionHelpers.hashForSignature(data: self.transaction.data) else {throw PlasmaErrors.StructureErrors.wrongData}
        var v = self.v
        if v > 3 {
            v -= BigUInt(27)
        }
        let vData = v.serialize().setLengthLeft(vByteLength)!
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: self.r, s: self.s) else {throw PlasmaErrors.StructureErrors.wrongData}
        guard let signerPubKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {throw PlasmaErrors.StructureErrors.wrongData}
        guard let addressData = try? TransactionHelpers.publicToAddressData(signerPubKey) else {throw PlasmaErrors.StructureErrors.wrongAddress}
        guard let address = EthereumAddress(addressData) else {throw PlasmaErrors.StructureErrors.wrongAddress}
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
