//
//  BlockHeader.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

public struct BlockHeader {
    
    public var blockNumber: BigUInt
    public var numberOfTxInBlock: BigUInt
    public var parentHash: Data
    public var merkleRootOfTheTxTree: Data
    public var v: BigUInt
    public var r: Data
    public var s: Data
    public var data: Data {
        return self.serialize()
    }
    
    public init?(blockNumber: BigUInt, numberOfTxInBlock: BigUInt, parentHash: Data, merkleRootOfTheTxTree: Data, v: BigUInt, r: Data, s: Data) {
        guard blockNumber.bitWidth <= blockNumberMaxWidth else {return nil}
        guard numberOfTxInBlock.bitWidth <= numberOfTxInBlockMaxWidth else {return nil}
        guard parentHash.count == parentHashByteLength else {return nil}
        guard merkleRootOfTheTxTree.count == merkleRootOfTheTxTreeByteLength else {return nil}
        guard v.bitWidth <= vMaxWidth else {return nil}
        guard r.count == rByteLength else {return nil}
        guard s.count == sByteLength else {return nil}
        
        guard v == 27 || v == 28 else {return nil}
        
        self.blockNumber = blockNumber
        self.numberOfTxInBlock = numberOfTxInBlock
        self.parentHash = parentHash
        self.merkleRootOfTheTxTree = merkleRootOfTheTxTree
        self.v = v
        self.r = r
        self.s = s
    }
    
    public init?(data: Data) {
        guard let item = RLP.decode(data) else {return nil}
        guard let dataArray = item[0] else {return nil}
        
        guard let blockNumberData = dataArray[0]?.data else {return nil}
        guard let numberOfTxInBlockData = dataArray[1]?.data else {return nil}
        guard let parentHash = dataArray[2]?.data else {return nil}
        guard let merkleRootOfTheTxTree = dataArray[3]?.data else {return nil}
        guard let vData = dataArray[4]?.data else {return nil}
        guard let r = dataArray[5]?.data else {return nil}
        guard let s = dataArray[6]?.data else {return nil}
        
        let blockNumber = BigUInt(blockNumberData)
        let numberOfTxInBlock = BigUInt(numberOfTxInBlockData)
        let v = BigUInt(vData)
        
        guard blockNumber.bitWidth <= blockNumberMaxWidth else {return nil}
        guard numberOfTxInBlock.bitWidth <= numberOfTxInBlockMaxWidth else {return nil}
        guard parentHash.count == parentHashByteLength else {return nil}
        guard merkleRootOfTheTxTree.count == merkleRootOfTheTxTreeByteLength else {return nil}
        guard v.bitWidth <= vMaxWidth else {return nil}
        guard r.count == rByteLength else {return nil}
        guard s.count == sByteLength else {return nil}
    
        self.blockNumber = blockNumber
        self.numberOfTxInBlock = numberOfTxInBlock
        self.parentHash = parentHash
        self.merkleRootOfTheTxTree = merkleRootOfTheTxTree
        self.v = v
        self.r = r
        self.s = s
    }
    
    public func serialize() -> Data {
        var d = Data()
        let blockNumberData = self.blockNumber.serialize().setLengthLeft(blockNumberByteLength)!
        let txNumberData = self.numberOfTxInBlock.serialize().setLengthLeft(txNumberInBlockByteLength)!
        
        d.append(blockNumberData)
        d.append(txNumberData)
        d.append(self.merkleRootOfTheTxTree)
        d.append(self.parentHash)
        
        let vData = self.v.serialize().setLengthLeft(vByteLength)!
        d.append(vData)
        d.append(self.r)
        d.append(self.s)
        
        precondition(d.count == blockHeaderByteLength)
        return d
    }
}

extension BlockHeader: Equatable {
    public static func ==(lhs: BlockHeader, rhs: BlockHeader) -> Bool {
        return lhs.blockNumber == rhs.blockNumber &&
            lhs.numberOfTxInBlock == rhs.numberOfTxInBlock &&
            lhs.parentHash == rhs.parentHash &&
            lhs.merkleRootOfTheTxTree == rhs.merkleRootOfTheTxTree &&
            lhs.v == rhs.v &&
            lhs.r == rhs.r &&
            lhs.s == rhs.s
    }
}
