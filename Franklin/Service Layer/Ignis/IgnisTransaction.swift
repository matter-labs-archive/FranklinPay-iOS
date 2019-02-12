//
//  IgnisTransaction.swift
//  Franklin
//
//  Created by Anton on 12/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress
import SwiftRLP
import BigInt
import secp256k1_swift

public struct SignedIgnisTransaction {
    public var tx: IgnisTransaction
    public var v: BigUInt
    public var r: Data
    public var s: Data
}

public class IgnisTransaction {
    public var from: BigUInt
    public var to: BigUInt
    public var amount: String
    public var fee: String
    public var nonce: BigUInt
    public var goodUntilBlock: BigUInt
    
    /// Returns serialized unsigned Transaction
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    public init(from: BigUInt, to: BigUInt, amount: String, fee: String, nonce: BigUInt, goodUntilBlock: BigUInt) {
        self.from = from
        self.to = to
        self.amount = amount
        self.fee = fee
        self.nonce = nonce
        self.goodUntilBlock = goodUntilBlock
    }
    
    public func prepareForRLP() -> [AnyObject] {
        let fromData = self.from.serialize()
        let toData = self.to.serialize()
        let amountData = Data(base64Encoded: self.amount) ?? Data()
        let feeData = Data(base64Encoded: self.fee) ?? Data()
        let nonceData = self.nonce.serialize()
        let goodUntilBlockData = self.goodUntilBlock.serialize()
        let totalData = [fromData, toData, amountData, feeData, nonceData, goodUntilBlockData] as [AnyObject]
        return totalData
    }
    
    public func serialize() throws -> Data {
        let dataArray = self.prepareForRLP()
        guard let encoded = RLP.encode(dataArray) else {throw PlasmaErrors.StructureErrors.cantEncodeData}
        return encoded
    }
    
    public func sign(privateKey: Data, useExtraEntropy: Bool = false) throws -> SignedIgnisTransaction {
        for _ in 0..<1024 {
            do {
                if let signature = try? signature(privateKey: privateKey, useExtraEntropy: useExtraEntropy) {
                    var v = BigUInt(signature.v)
                    if (v < 27) {
                        v += BigUInt(27)
                    }
                    let r = signature.r
                    let s = signature.s
                    let signedTransaction = SignedIgnisTransaction(tx: self,
                                                                   v: v,
                                                                   r: r,
                                                                   s: s)
                    return signedTransaction
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
}

public struct IgnisHistoryTransaction {
    let hash: String
    let from: EthereumAddress
    let to: EthereumAddress
    let amount: Double
    let isPending: Bool
}

extension IgnisHistoryTransaction: Equatable {
    public static func ==(lhs: IgnisHistoryTransaction, rhs: IgnisHistoryTransaction) -> Bool {
        return lhs.hash == rhs.hash
    }
}
