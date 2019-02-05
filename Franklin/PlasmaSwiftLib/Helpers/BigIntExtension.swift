//
//  BigIntExtension.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 19.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import BigInt

extension BigInt {
    public func toTwosComplement() -> Data {
        if (self.sign == BigInt.Sign.plus) {
            return self.magnitude.serialize()
        } else {
            let serializedLength = self.magnitude.serialize().count
            let MAX = BigUInt(1) << (serializedLength*8)
            let twoComplement = MAX - self.magnitude
            return twoComplement.serialize()
        }
    }
}

extension BigUInt {
    func abiEncode(bits: UInt64) -> Data? {
        let data = self.serialize()
        let paddedLength = UInt64(ceil((Double(bits)/8.0)))
        let padded = data.setLengthLeft(paddedLength)
        return padded
    }
}

extension BigInt {
    func abiEncode(bits: UInt64) -> Data? {
        let isNegative = self < (BigInt(0))
        let data = self.toTwosComplement()
        let paddedLength = UInt64(ceil((Double(bits)/8.0)))
        let padded = data.setLengthLeft(paddedLength, isNegative: isNegative)
        return padded
    }
}

extension BigInt {
    static func fromTwosComplement(data: Data) -> BigInt {
        let isPositive = ((data[0] & 128) >> 7) == 0
        if (isPositive) {
            let magnitude = BigUInt(data)
            return BigInt(magnitude)
        } else {
            let MAX = (BigUInt(1) << (data.count*8))
            let magnitude = MAX - BigUInt(data)
            let bigint = BigInt(0) - BigInt(magnitude)
            return bigint
        }
    }
}
