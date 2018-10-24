//
//  Output.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import SwiftRLP
import BigInt

public struct TransactionOutput {
    
    let helpers = TransactionHelpers()
    
    public var outputNumberInTx: BigUInt
    public var receiverEthereumAddress: EthereumAddress
    public var amount: BigUInt
    public var data: Data {
        return self.serialize()
    }
    
    public init?(outputNumberInTx: BigUInt, receiverEthereumAddress: EthereumAddress, amount: BigUInt){
        guard outputNumberInTx.bitWidth <= outputNumberInTxMaxWidth else {return nil}
        guard receiverEthereumAddress.addressData.count <= receiverEthereumAddressByteLength else {return nil}
        guard amount.bitWidth <= amountMaxWidth else {return nil}
    
        self.outputNumberInTx = outputNumberInTx
        self.receiverEthereumAddress = receiverEthereumAddress
        self.amount = amount
    }
    
    public init?(data: Data) {
        
        guard let dataArray = RLP.decode(data) else {return nil}
        guard dataArray.isList else {return nil}
        guard dataArray.count == 3 else {return nil}
        
        guard let outputNumberInTxData = dataArray[0]?.data else {return nil}
        guard let receiverEthereumAddressData = dataArray[1]?.data else {return nil}
        guard let amountData = dataArray[2]?.data else {return nil}
        
        let outputNumberInTx = BigUInt(outputNumberInTxData)
        guard let receiverEthereumAddress = EthereumAddress(receiverEthereumAddressData) else {return nil}
        let amount = BigUInt(amountData)
        
        guard outputNumberInTx.bitWidth <= outputNumberInTxMaxWidth else {return nil}
        guard receiverEthereumAddress.addressData.count <= receiverEthereumAddressByteLength else {return nil}
        guard amount.bitWidth <= amountMaxWidth else {return nil}
        
        self.outputNumberInTx = outputNumberInTx
        self.receiverEthereumAddress = receiverEthereumAddress
        self.amount = amount
    }
    
    public func serialize() -> Data {
        let dataArray = self.prepareForRLP()
        let encoded = RLP.encode(dataArray)!
        return encoded
    }
    
    public func prepareForRLP() -> [AnyObject] {
        let outputNumberData = self.outputNumberInTx.serialize().setLengthLeft(outputNumberInTxByteLength)
        let addressData = self.receiverEthereumAddress.addressData
        let amountData = self.amount.serialize().setLengthLeft(amountByteLength)
        let dataArray = [outputNumberData, addressData, amountData] as [AnyObject]
        return dataArray
    }
}

extension TransactionOutput: Equatable {
    public static func ==(lhs: TransactionOutput, rhs: TransactionOutput) -> Bool {
        return lhs.outputNumberInTx == rhs.outputNumberInTx
            && lhs.receiverEthereumAddress.address == rhs.receiverEthereumAddress.address
            && lhs.amount == rhs.amount
            && lhs.data == rhs.data
    }
}
