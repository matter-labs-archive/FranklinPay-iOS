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

public struct SignedTransaction {
    
    private let helpers = TransactionHelpers()
    
    public var transaction: Transaction
    public var v: BigUInt
    public var r: Data
    public var s: Data
    public var data: Data {
        return self.serialize()
    }
    
    public var sender: EthereumAddress? {
        return self.recoverSender()
    }
    
    public init() {
        self.transaction = Transaction()
        self.v = BigUInt(0)
        self.r = Data(repeating: 0, count: Int(rByteLength))
        self.s = Data(repeating: 0, count: Int(sByteLength))
    }
    
    public init?(transaction: Transaction, v: BigUInt, r: Data, s: Data){
        guard v.bitWidth <= vMaxWidth else {return nil}
        guard r.count == rByteLength else {return nil}
        guard s.count == sByteLength else {return nil}
        
        guard v == 27 || v == 28 else {return nil}
        
        self.transaction = transaction
        self.v = v
        self.r = r
        self.s = s
    }
    
    public init?(data: Data) {
        
        guard let item = RLP.decode(data) else {return nil}
        guard let dataArray = item[0] else {return nil}
        guard dataArray.isList else {return nil}
        guard dataArray.count == 4 else {return nil}
        guard let transactionData = dataArray[0]?.data else {return nil}
        guard let vData = dataArray[1]?.data else {return nil}
        guard let rData = dataArray[2]?.data else {return nil}
        guard let sData = dataArray[3]?.data else {return nil}
        
        let v = BigUInt(vData)
        guard v.bitWidth <= vMaxWidth else {return nil}
        
        guard rData.count == rByteLength else {return nil}
        guard sData.count == sByteLength else {return nil}
        
        guard let transaction = Transaction.init(data: transactionData) else {return nil}
        
        self.v = v
        self.r = rData
        self.s = sData
        self.transaction = transaction
    }
    
    public func prepareForRLP() -> [AnyObject] {
        let vData = self.v.serialize().setLengthLeft(vByteLength)!
        let transactionObject = self.transaction.prepareForRLP()
        let dataArray = [transactionObject, vData, self.r, self.s] as [AnyObject]
        return dataArray
    }
    
    public func serialize() -> Data {
        let dataArray = self.prepareForRLP()
        let encoded = RLP.encode(dataArray)!
        return encoded
    }
    
    public func recoverSender() -> EthereumAddress? {
        guard let hash = TransactionHelpers.hashForSignature(data: self.transaction.data) else {return nil}
        var v = self.v
        if v > 3 {
            v = v - BigUInt(27)
        }
        let vData = v.serialize().setLengthLeft(vByteLength)!
        guard let signatureData = SECP256K1.marshalSignature(v: vData, r: self.r, s: self.s) else {return nil}
        guard let signerPubKey = SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else {return nil}
        guard let addressData = TransactionHelpers.publicToAddressData(signerPubKey) else {return nil}
        return EthereumAddress(addressData)
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
