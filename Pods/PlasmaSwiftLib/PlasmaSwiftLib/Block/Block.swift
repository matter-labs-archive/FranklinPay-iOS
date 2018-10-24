//
//  Block.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

// No merkle root checking yet!

import Foundation
import SwiftRLP
import BigInt

class Block {
    public var blockHeader: BlockHeader
    public var signedTransactions: [SignedTransaction]
    public var data: Data {
        return self.serialize()
    }
    
    public init?(blockHeader: BlockHeader, signedTransactions: [SignedTransaction]){
        
        self.blockHeader = blockHeader
        self.signedTransactions = signedTransactions
    }
    
    public init?(data: Data) {
        guard data.count > blockHeaderByteLength else {return nil}
        let headerData = Data(data[0 ..< blockHeaderByteLength])
        guard let blockHeader = BlockHeader(data: headerData) else {return nil}
        
        let transactionsData = Data(data[Int(blockHeaderByteLength) ..< data.count])
        guard let item = RLP.decode(transactionsData) else {return nil}
        guard let dataArray = item[0] else {return nil}
        guard dataArray.isList else {return nil}
        self.blockHeader = blockHeader
        var transactions = [SignedTransaction]()
        transactions.reserveCapacity(dataArray.count!)
        for i in 0 ..< dataArray.count! {
            guard let txData = dataArray[i]!.data else {return nil}
            guard let tx = SignedTransaction(data: txData) else {return nil}
            transactions.append(tx)
        }
        self.signedTransactions = transactions
    }
    
    public func serialize() -> Data {
        let headerData = self.blockHeader.data
        var txArray = [Data]()
        txArray.reserveCapacity(self.signedTransactions.count)
        for tx in self.signedTransactions {
            txArray.append(tx.data)
        }
        let txRLP = RLP.encode(txArray as [AnyObject])!
        return headerData + txRLP
    }
}

extension Block: Equatable {
    public static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.blockHeader == rhs.blockHeader &&
            lhs.signedTransactions == rhs.signedTransactions
        
    }
}
