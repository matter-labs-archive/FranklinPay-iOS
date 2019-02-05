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

/// The header of Block (first 137 bytes)
public struct BlockHeader {
    public var blockNumber: BigUInt!
    public var numberOfTxInBlock: BigUInt!
    public var parentHash: Data!
    public var merkleRootOfTheTxTree: Data!
    public var v: BigUInt!
    public var r: Data!
    public var s: Data!
    
    /// Returns serialized Block Header
    public var data: Data {
        do {
            return try self.serialize()
        } catch {
            return Data()
        }
    }

    /// Creates BlockHeader object that implement Block header in Block object (first 137 bytes)
    ///
    /// - Parameters:
    ///   - blockNumber: the number of block, used in the main chain to double check proper ordering
    ///   - numberOfTxInBlock: the number of transactions in block
    ///   - parentHash: hash of the previous block, hashes the full header
    ///   - merkleRootOfTheTxTree: Merkle root of the transactions tree
    ///   - v: the recovery id
    ///   - r: output of the signature
    ///   - s: output of the signature
    /// - Throws: `PlasmaErrors.StructureErrors.wrongBitWidth` if bytes count in some parameter is wrong
    public init(blockNumber: BigUInt, numberOfTxInBlock: BigUInt, parentHash: Data, merkleRootOfTheTxTree: Data, v: BigUInt, r: Data, s: Data) throws {
        guard blockNumber.bitWidth <= blockNumberMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard numberOfTxInBlock.bitWidth <= numberOfTxInBlockMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard parentHash.count <= parentHashByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard merkleRootOfTheTxTree.count <= merkleRootOfTheTxTreeByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard v.bitWidth <= vMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard r.count <= rByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard s.count <= sByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}

        guard v == 27 || v == 28 else {throw PlasmaErrors.StructureErrors.wrongData}

        self.blockNumber = blockNumber
        self.numberOfTxInBlock = numberOfTxInBlock
        self.parentHash = parentHash
        self.merkleRootOfTheTxTree = merkleRootOfTheTxTree
        self.v = v
        self.r = r
        self.s = s
    }
    
    private func getElements(from dataStringArray: [String]) -> [String] {
        var max = 0
        var min = 0
        var elements = [String]()
        for i in 0..<7 {
            var bytes = 0
            switch i {
            case 0:
                bytes = Int(blockNumberByteLength)
            case 1:
                bytes = Int(blockNumberByteLength)
            case 2:
                bytes = Int(parentHashByteLength)
            case 3:
                bytes = Int(merkleRootOfTheTxTreeByteLength)
            case 4:
                bytes = Int(vByteLength)
            case 5:
                bytes = Int(rByteLength)
            default:
                bytes = Int(sByteLength)
            }
            min = max
            max += bytes
            let elementSlice = dataStringArray[min..<max]
            let elementArray: [String] = Array(elementSlice)
            let element = elementArray.joined()
            elements.append(element)
        }
        return elements
    }
    
    /// Creates BlockHeader object that implement Block header in Block object (first 137 bytes)
    ///
    /// - Parameter data: encoded Data of SignedTransaction
    /// - Throws: throws various `PlasmaErrors.StructureErrors` if decoding is wrong or decoded data is wrong in some way
    public init(data: Data) throws {
        let dataString = data.toHexString()
        let dataStringArray = dataString.split(intoChunksOf: 2)
        
        guard dataStringArray.count == Int(blockHeaderByteLength) else {throw PlasmaErrors.StructureErrors.wrongDataCount}
        
        let elements = getElements(from: dataStringArray)
        
        guard let blockNumberDec = UInt8(elements[0], radix: 16) else {throw PlasmaErrors.StructureErrors.wrongData}
        let blockNumber = BigUInt(blockNumberDec)
        guard let numberOfTxInBlockDec = UInt8(elements[1], radix: 16) else {throw PlasmaErrors.StructureErrors.wrongData}
        let numberOfTxInBlock = BigUInt(numberOfTxInBlockDec)
        let parentHash = Data(hex: elements[2])
        let merkleRootOfTheTxTree = Data(hex: elements[3])
        guard let vDec = UInt8(elements[4], radix: 16) else {throw PlasmaErrors.StructureErrors.wrongData}
        let v = BigUInt(vDec)
        let r = Data(hex: elements[5])
        let s = Data(hex: elements[6])

        guard blockNumber.bitWidth <= blockNumberMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard numberOfTxInBlock.bitWidth <= numberOfTxInBlockMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard parentHash.count <= parentHashByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard merkleRootOfTheTxTree.count <= merkleRootOfTheTxTreeByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard v.bitWidth <= vMaxWidth else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard r.count <= rByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}
        guard s.count <= sByteLength else {throw PlasmaErrors.StructureErrors.wrongBitWidth}

        self.blockNumber = blockNumber
        self.numberOfTxInBlock = numberOfTxInBlock
        self.parentHash = parentHash
        self.merkleRootOfTheTxTree = merkleRootOfTheTxTree
        self.v = v
        self.r = r
        self.s = s
    }

    /// Serializes BlockHeader
    ///
    /// - Returns: encoded bytes `Data` value that contains the base-256 representation of this header
    /// - Throws: `PlasmaErrors.StructureErrors.cantEncodeData` if data can't be encoded
    public func serialize() throws -> Data {
        var d = Data()
        guard let blockNumberData = self.blockNumber.serialize().setLengthLeft(blockNumberByteLength) else {throw PlasmaErrors.StructureErrors.cantEncodeData}
        guard let txNumberData = self.numberOfTxInBlock.serialize().setLengthLeft(txNumberInBlockByteLength) else {throw PlasmaErrors.StructureErrors.cantEncodeData}

        d.append(blockNumberData)
        d.append(txNumberData)
        d.append(self.parentHash)
        d.append(self.merkleRootOfTheTxTree)

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
