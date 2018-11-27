//
//  Constants.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 18.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt

internal let bit: UInt64 = 8

public let blockNumberByteLength: UInt64 = 4
public let blockNumberMaxWidth = blockNumberByteLength * bit

public let txNumberInBlockByteLength: UInt64 = 4
public let txNumberInBlockMaxWidth = txNumberInBlockByteLength * bit

public let outputNumberInTxByteLength: UInt64 = 1
public let outputNumberInTxMaxWidth = outputNumberInTxByteLength * bit

public let amountByteLength: UInt64 = 32
public let amountMaxWidth = amountByteLength * bit

public let receiverEthereumAddressByteLength: UInt64 = 20
public let receiverEthereumAddressMaxWidth = receiverEthereumAddressByteLength * bit

public let txTypeByteLength: UInt64 = 1
public let txTypeMaxWidth = txTypeByteLength * bit

public let vByteLength: UInt64 = 1
public let vMaxWidth = vByteLength * bit

public let rByteLength: UInt64 = 32
public let rMaxWidth = rByteLength * bit

public let sByteLength: UInt64 = 32
public let sMaxWidth = sByteLength * bit

public let inputsArrayMax = 3
public let outputsArrayMax = 3

public let numberOfTxInBlockByteLength: UInt64 = 4
public let numberOfTxInBlockMaxWidth = numberOfTxInBlockByteLength * bit

public let parentHashByteLength: UInt64 = 32
public let parentHashMaxWidth = parentHashByteLength * bit

public let merkleRootOfTheTxTreeByteLength: UInt64 = 32
public let merkleRootOfTheTxTreeMaxWidth = merkleRootOfTheTxTreeByteLength * bit

public let blockHeaderByteLength: UInt64 = 137

public let emptyTx: Data = Data(hex: "0xf847c300c0c000a00000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000")
