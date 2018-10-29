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

public struct TransactionInput {
    public var blockNumber: BigUInt
    public var txNumberInBlock: BigUInt
    public var outputNumberInTx: BigUInt
    public var amount: BigUInt
    public var data: Data {
        return self.serialize()
    }
    
    public init?(blockNumber: BigUInt, txNumberInBlock: BigUInt, outputNumberInTx: BigUInt, amount: BigUInt) {
        
        guard blockNumber.bitWidth <= blockNumberMaxWidth else {return nil}
        guard txNumberInBlock.bitWidth <= txNumberInBlockMaxWidth else {return nil}
        guard outputNumberInTx.bitWidth <= outputNumberInTxMaxWidth else {return nil}
        guard amount.bitWidth <= amountMaxWidth else {return nil}
        
        self.blockNumber = blockNumber
        self.txNumberInBlock = txNumberInBlock
        self.outputNumberInTx = outputNumberInTx
        self.amount = amount
    }
    
    public init?(data: Data) {
        
        guard let dataDecoded = RLP.decode(data) else {return nil}
        guard dataDecoded.isList else {return nil}
        guard let count = dataDecoded.count else {return nil}
        let dataArray: RLP.RLPItem
        guard let firstItem = dataDecoded[0] else {return nil}
        if count > 1 {
            dataArray = dataDecoded
        } else {
            dataArray = firstItem
        }
        guard dataArray.count == 4 else {
            print("Wrong decoded input")
            return nil
        }
        guard let blockNumberData = dataArray[0]?.data else {return nil}
        guard let txNumberInBlockData = dataArray[1]?.data else {return nil}
        guard let outputNumberInTxData = dataArray[2]?.data else {return nil}
        guard let amountData = dataArray[3]?.data else {return nil}
        
        let blockNumber = BigUInt(blockNumberData)
        let txNumberInBlock = BigUInt(txNumberInBlockData)
        let outputNumberInTx = BigUInt(outputNumberInTxData)
        let amount = BigUInt(amountData)
        
        guard blockNumber.bitWidth <= blockNumberMaxWidth else {return nil}
        guard txNumberInBlock.bitWidth <= txNumberInBlockMaxWidth else {return nil}
        guard outputNumberInTx.bitWidth <= outputNumberInTxMaxWidth else {return nil}
        guard amount.bitWidth <= amountMaxWidth else {return nil}
        
        self.blockNumber = blockNumber
        self.txNumberInBlock = txNumberInBlock
        self.outputNumberInTx = outputNumberInTx
        self.amount = amount
    }
    
    public func serialize() -> Data {
        let dataArray = self.prepareForRLP()
        let encoded = RLP.encode(dataArray)!
        return encoded
    }
    
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
