//
//  BlockHelpers.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 19.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

class BlockHelpers {
    
//    func serializeBlock(dataArray: RLP.RLPItem) -> Block? {
//        guard let blockHeaderData = dataArray[0] else {return nil}
//        guard let signedTransactionsData = dataArray[1] else {return nil}
//        
//        guard let blockHeader = serializeBlockHeader(dataArray: blockHeaderData) else {return nil}
//        
//        var signedTransactions: [SignedTransaction] = []
//        let transactionsCount = signedTransactionsData.count ?? 0
//        let convenienceCount = Int(transactionsCount/2)
//        for i in -convenienceCount ..< convenienceCount {
//            if let signedTransactionData = signedTransactionsData[i + convenienceCount] {
//                if let signedTransaction = transactionHelpers.serializeSignedTransaction(signedTransactionData) {
//                    signedTransactions.append(signedTransaction)
//                }
//            }
//        }
//        
//        let block = Block(blockHeader: blockHeader, signedTransactions: signedTransactions)
//        return block
//    }
//    
//    func blockHeaderToAnyObjectArray(blockHeader: BlockHeader) -> [AnyObject] {
//        return blockHeader.blockHeader
//    }
}
