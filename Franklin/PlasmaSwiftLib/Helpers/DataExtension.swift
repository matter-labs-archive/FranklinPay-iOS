//
//  Data+Extension.swift
//  web3swift
//
//  Created by Alexander Vlasov on 15.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import CryptoSwift

extension Data {

    public init<T>(fromArray values: [T]) {
        var values = values
        self.init(buffer: UnsafeBufferPointer(start: &values, count: values.count))
    }

    public func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            [T](UnsafeBufferPointer(start: $0, count: self.count/MemoryLayout<T>.stride))
        }
    }

    public func constantTimeComparisonTo(_ other: Data?) -> Bool {
        guard let rhs = other else {return false}
        guard self.count == rhs.count else {return false}
        var difference = UInt8(0x00)
        for i in 0..<self.count { // compare full length
            difference |= self[i] ^ rhs[i] //constant time
        }
        return difference == UInt8(0x00)
    }

    public static func zero(_ data: inout Data) {
        let count = data.count
        data.withUnsafeMutableBytes { (dataPtr: UnsafeMutablePointer<UInt8>) in
            //            var rawPtr = UnsafeMutableRawPointer(dataPtr)
            //            sodium_memzero(rawPtr, count)
            dataPtr.initialize(repeating: 0, count: count)
        }
    }
    
    public static func randomBytes(length: Int) -> Data? {
        for _ in 0...1024 {
            var data = Data(repeating: 0, count: length)
            let result = data.withUnsafeMutableBytes { (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
                SecRandomCopyBytes(kSecRandomDefault, 32, mutableBytes)
            }
            if result == errSecSuccess {
                return data
            }
        }
        return nil
    }

    public func bitsInRange(_ startingBit: Int, _ length: Int) -> UInt64? { //return max of 8 bytes for simplicity, non-public
        if startingBit + length / 8 > self.count, length > 64, startingBit > 0, length >= 1 {return nil}
        let bytes = self[(startingBit/8) ..< (startingBit+length+7)/8]
        let padding = Data(repeating: 0, count: 8 - bytes.count)
        let padded = bytes + padding
        guard padded.count == 8 else {return nil}
        var uintRepresentation = UInt64(bigEndian: padded.withUnsafeBytes { $0.pointee })
        uintRepresentation = uintRepresentation << (startingBit % 8)
        uintRepresentation = uintRepresentation >> UInt64(64 - length)
        return uintRepresentation
    }
}

extension Data {
    public func setLengthLeft(_ toBytes: UInt64, isNegative: Bool = false ) -> Data? {
        let existingLength = UInt64(self.count)
        if (existingLength == toBytes) {
            return Data(self)
        } else if (existingLength > toBytes) {
            return nil
        }
        var data: Data
        if (isNegative) {
            data = Data(repeating: UInt8(255), count: Int(toBytes - existingLength))
        } else {
            data = Data(repeating: UInt8(0), count: Int(toBytes - existingLength))
        }
        data.append(self)
        return data
    }

    public func setLengthRight(_ toBytes: UInt64, isNegative: Bool = false ) -> Data? {
        let existingLength = UInt64(self.count)
        if (existingLength == toBytes) {
            return Data(self)
        } else if (existingLength > toBytes) {
            return nil
        }
        var data: Data = Data()
        data.append(self)
        if (isNegative) {
            data.append(Data(repeating: UInt8(255), count: Int(toBytes - existingLength)))
        } else {
            data.append(Data(repeating: UInt8(0), count: Int(toBytes - existingLength)))
        }
        return data
    }
}
