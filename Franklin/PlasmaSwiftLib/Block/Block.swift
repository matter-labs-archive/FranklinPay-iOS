//
//  Block.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt
import Web3swift

/// Plasma Block in storage
public class Block {
    public var blockHeader: BlockHeader
    public var signedTransactions: [SignedTransaction]
    
    /// Merkle tree of transactions in this Block
    public var merkleTree: PaddabbleTree? {
        let transactions = self.signedTransactions
        var contents = [ContentProtocol]()
        for tx in transactions {
            let raw = TreeContent(tx.data)
            contents.append(raw)
        }
        let paddingElement = TreeContent(emptyTx)
        let tree = PaddabbleTree(contents, paddingElement)
        return tree
    }
    
    /// Returns serialized Block
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    /// Creates Block object that implement Plasma Block in storage
    ///
    /// - Parameters:
    ///   - blockHeader: BlockHeader, first 137 bytes
    ///   - signedTransactions: RLP encoded array of SignedTransaction
    public init(blockHeader: BlockHeader, signedTransactions: [SignedTransaction]) {
        self.blockHeader = blockHeader
        self.signedTransactions = signedTransactions
    }

    /// Creates Block object that implement Plasma Block in storage
    ///
    /// - Parameter data: encoded Data of Block
    /// - Throws: throws various `PlasmaErrors.StructureErrors` if decoding is wrong or decoded data is wrong in some way
    public init(data: Data) throws {
        guard data.count > blockHeaderByteLength else {throw PlasmaErrors.StructureErrors.wrongDataCount}
        let headerData = Data(data[0 ..< blockHeaderByteLength])
        guard let blockHeader = try? BlockHeader(data: headerData) else {throw PlasmaErrors.StructureErrors.wrongData}
        self.blockHeader = blockHeader

        let signedTransactionsData = Data(data[Int(blockHeaderByteLength) ..< data.count])
        guard let item = RLP.decode(signedTransactionsData) else {throw PlasmaErrors.StructureErrors.wrongData}
        guard item.isList else {throw PlasmaErrors.StructureErrors.isNotList}
        var signedTransactions = [SignedTransaction]()
        signedTransactions.reserveCapacity(item.count!)
        print("signed tx count: \(item.count!)")
        for i in 0 ..< item.count! {
            guard let txData = item[i]!.data else {throw PlasmaErrors.StructureErrors.isNotData}
            
            guard let tx = try? SignedTransaction(data: txData) else {throw PlasmaErrors.StructureErrors.wrongData}
            signedTransactions.append(tx)
        }
        self.signedTransactions = signedTransactions
        guard let tree = self.merkleTree else {
            throw PlasmaErrors.StructureErrors.wrongData
        }
        guard tree.merkleRoot == self.blockHeader.merkleRootOfTheTxTree else {
            throw PlasmaErrors.StructureErrors.wrongData
        }
    }

    /// Serializes Block
    ///
    /// - Returns: encoded bytes `Data` value that contains merged the base-256 representation of BlockHeader and encoded AnyObject array consisted of SignedTransaction items
    /// - Throws: `PlasmaErrors.StructureErrors.cantEncodeData` if data can't be encoded
    public func serialize() throws -> Data {
        let headerData = self.blockHeader.data
        var txArray = [Data]()
        txArray.reserveCapacity(self.signedTransactions.count)
        for tx in self.signedTransactions {
            txArray.append(tx.data)
        }
        guard let txRLP = RLP.encode(txArray as [AnyObject]) else {throw PlasmaErrors.StructureErrors.cantEncodeData}
        return headerData + txRLP
    }
    
    /// Proves that the transaction is in this Block transactions set
    ///
    /// - Parameter transaction: signed transaction that needs to be proved
    /// - Returns: tuple:
    ///     - tx: signed transaction from parameters
    ///     - proof: Data indicator that signed transaction is in Block transactions set
    /// - Throws: `PlasmaErrors.StructureErrors.wrongData` if something in proving is wrong
    public func getProof(for transaction: SignedTransaction) throws -> (tx: SignedTransaction, proof: Data) {
        guard let tree = self.merkleTree else {throw PlasmaErrors.StructureErrors.wrongData}
        for (counter, tx) in self.signedTransactions.enumerated() {
            let serializedTx = tx.data
            if serializedTx == transaction.data {
                guard let proof =  tree.makeBinaryProof(counter) else {throw PlasmaErrors.StructureErrors.wrongData}
                return (tx, proof)
            }
        }
        throw PlasmaErrors.StructureErrors.wrongData
    }
    
    /// Proves that the transaction is in this Block transactions set
    ///
    /// - Parameter txNumber: number of signed transaction that needs to be proved
    /// - Returns: tuple:
    ///     - tx: signed transaction from parameters
    ///     - proof: Data indicator that signed transaction is in Block transactions set
    /// - Throws: `PlasmaErrors.StructureErrors.wrongData` if something in proving is wrong
    public func getProofForTransactionByNumber(txNumber: BigUInt) throws -> (tx: SignedTransaction, proof: Data) {
        let num = Int(txNumber)
        guard let tree = self.merkleTree else {throw PlasmaErrors.StructureErrors.wrongData}
        guard num < self.signedTransactions.count else {throw PlasmaErrors.StructureErrors.wrongData}
        let tx = self.signedTransactions[num]
        guard let proof = tree.makeBinaryProof(num) else {throw PlasmaErrors.StructureErrors.wrongData}
        return (tx, proof)
    }
}

extension Block: Equatable {
    public static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.blockHeader == rhs.blockHeader &&
            lhs.signedTransactions == rhs.signedTransactions
    }
}

/// Merkle Tree content
public struct TreeContent: ContentProtocol {
    /// Hash of the Merkle tree content
    ///
    /// - Parameter hasher: hash function
    /// - Returns: hash of the Merkle tree content
    public func getHash(_ hasher: TreeHasher) -> Data {
        let h = Web3.Utils.hashPersonalMessage(self.data)!
        return h
    }
    
    /// Checks if some Merkle tree content equal to another
    /// - Parameter other: other Content
    /// - Returns: bool value
    public func isEqualTo(_ other: ContentProtocol) -> Bool {
        return self.data == other.data
    }
    
    public var data: Data
    
    /// Creates TreeContent object
    ///
    /// - Parameter data: data of the content
    init(_ data: Data) {
        self.data = data
    }
}

extension TreeContent: Equatable {
    public static func ==(lhs: TreeContent, rhs: TreeContent) -> Bool {
        return lhs.data == rhs.data
    }
}
