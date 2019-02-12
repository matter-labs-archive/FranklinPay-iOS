//
//  TransactionHelpers.swift
//  PlasmaSwiftLib
//
//  Created by Anton Grigorev on 13/12/2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import Foundation
import secp256k1_swift

/// Some helpful methods for Transaction
public struct TransactionHelpers {
    
    /// Returns hash of the signature
    ///
    /// - Parameter data: signature data
    /// - Returns: hash of that signature
    /// - Throws: `StructureErrors.wrongData` if data is wrong
    static func hashForSignature(data: Data) throws -> Data {
        let hash = try TransactionHelpers.hashPersonalMessage(data)
        return hash
    }
    
    static func hashPersonalMessage(_ personalMessage: Data) throws -> Data {
        var prefix = "\u{19}Ethereum Signed Message:\n"
        prefix += String(personalMessage.count)
        guard let prefixData = prefix.data(using: .ascii) else {throw PlasmaErrors.StructureErrors.wrongData}
        var data = Data()
        if personalMessage.count >= prefixData.count && prefixData == personalMessage[0 ..< prefixData.count] {
            data.append(personalMessage)
        } else {
            data.append(prefixData)
            data.append(personalMessage)
        }
        let hash = data.sha3(.keccak256)
        return hash
    }
    
    /// Returns address hash from public key data
    ///
    /// - Parameter publicKey: public key data
    /// - Returns: address data hash
    /// - Throws: `StructureErrors.wrongDataCount` if data is wrong or `StructureErrors.wrongDataCount` if data count is wrong
    static func publicToAddressData(_ publicKey: Data) throws -> Data {
        if publicKey.count == 33 {
            guard let decompressedKey = SECP256K1.combineSerializedPublicKeys(keys: [publicKey], outputCompressed: false) else {throw PlasmaErrors.StructureErrors.wrongData}
            return try publicToAddressData(decompressedKey)
        }
        var stipped = publicKey
        if (stipped.count == 65) {
            if (stipped[0] != 4) {
                throw PlasmaErrors.StructureErrors.wrongData
            }
            stipped = stipped[1...64]
        }
        if (stipped.count != 64) {
            throw PlasmaErrors.StructureErrors.wrongDataCount
        }
        let sha3 = stipped.sha3(.keccak256)
        let addressData = sha3[12...31]
        return addressData
    }
}
