//
//  Transaction.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt
import secp256k1_swift

public class Transaction {
    public enum TransactionType {
        case null
        case fund
        case split
        case merge
        
        public var data: Data {
            switch self {
            case .null:
                return Data([UInt8(0)])
            case .split:
                return Data([UInt8(1)])
            case .merge:
                return Data([UInt8(2)])
            case .fund:
                return Data([UInt8(4)])
            }
        }
        
        public init?(byte: UInt8) {
            if byte == 0 {
                self = .null
                return
            } else if byte == 1 {
                self = .split
                return
            } else if byte == 2 {
                self = .merge
                return
            } else if byte == 4 {
                self = .fund
                return
            }
            return nil
        }
        
    }
    
    public var txType: TransactionType
    public var inputs: Array<TransactionInput>
    public var outputs: Array<TransactionOutput>
    public var data: Data {
        return self.serialize()
    }
    
    public init() {
        self.txType = .null
        self.inputs = [TransactionInput]()
        self.outputs = [TransactionOutput]()
    }
    
    public init?(txType: TransactionType, inputs: Array<TransactionInput>, outputs: Array<TransactionOutput>) {
        guard inputs.count <= inputsArrayMax else {return nil}
        guard outputs.count <= outputsArrayMax else {return nil}
        
        self.txType = txType
        self.inputs = inputs
        self.outputs = outputs
    }
    
    public init?(data: Data) {
        
        guard let item = RLP.decode(data) else {return nil}
        guard item.isList else {return nil}
        guard let count = item.count else {return nil}
        let dataArray: RLP.RLPItem
        
        guard let firstItem = item[0] else {return nil}
        if count > 1 {
            dataArray = item
        } else {
            dataArray = firstItem
        }
        
        guard dataArray.count == 3 else {
            print("Wrong decoded transaction")
            return nil
        }
        
        guard let txTypeData = dataArray[0]?.data else {return nil}
        guard let inputsData = dataArray[1] else {return nil}
        guard let outputsData = dataArray[2] else {return nil}
        
        guard txTypeData.count == txTypeByteLength else {return nil}
        guard let txType = TransactionType(byte: txTypeData.first!) else {return nil}
        self.txType = txType
        
        var inputs = [TransactionInput]()
        if inputsData.isList {
            inputs.reserveCapacity(inputsData.count!)
            for inputIndex in 0 ..< inputsData.count! {
                guard let inputData = inputsData[inputIndex]!.data else {return nil}
                guard let input = TransactionInput(data: inputData) else {return nil}
                inputs.append(input)
            }
        }
        
        var outputs = [TransactionOutput]()
        if outputsData.isList {
            outputs.reserveCapacity(outputsData.count!)
            for outputIndex in 0 ..< outputsData.count! {
                guard let outputData = outputsData[outputIndex]!.data else {return nil}
                guard let output = TransactionOutput(data: outputData) else {return nil}
                outputs.append(output)
            }
        }
        
        self.inputs = inputs
        self.outputs = outputs
    }
    
    public func sign(privateKey: Data, useExtraEntropy: Bool = false) -> SignedTransaction? {
        for _ in 0..<1024 {
            if let signature = signature(privateKey: privateKey, useExtraEntropy: useExtraEntropy) {
                var v = BigUInt(signature.v)
                if (v < 27) {
                    v += BigUInt(27)
                }
                let r = signature.r
                let s = signature.s
                if let signedTransaction = SignedTransaction(transaction: self,
                                                          v: v,
                                                          r: r,
                                                          s: s) {return signedTransaction}
            }
        }
        return nil
    }
    
    private func signature(privateKey: Data, useExtraEntropy: Bool = false) -> SECP256K1.UnmarshaledSignature? {
        guard let hash = TransactionHelpers.hashForSignature(data: self.data) else {return nil}
        let signature = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        guard let serializedSignature = signature.serializedSignature else {return nil}
        guard let unmarshalledSignature = SECP256K1.unmarshalSignature(signatureData: serializedSignature) else {
            return nil
        }
        return unmarshalledSignature
    }
    
    public func prepareForRLP() -> [AnyObject] {
        let txTypeData = self.txType.data
        var inputsData = [[AnyObject]]()
        inputsData.reserveCapacity(self.inputs.count)
        for input in self.inputs {
            inputsData.append(input.prepareForRLP())
        }
        var outputsData = [[AnyObject]]()
        outputsData.reserveCapacity(self.outputs.count)
        for output in self.outputs {
            outputsData.append(output.prepareForRLP())
        }
        let totalData = [txTypeData, inputsData, outputsData] as [AnyObject]
        return totalData
    }
    
    public func serialize() -> Data {
        let dataArray = self.prepareForRLP()
        let encoded = RLP.encode(dataArray)!
        return encoded
    }
}

extension Transaction: Equatable {
    public static func ==(lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.txType == rhs.txType &&
            lhs.inputs == rhs.inputs &&
            lhs.outputs == rhs.outputs &&
            lhs.data == rhs.data
    }
}
