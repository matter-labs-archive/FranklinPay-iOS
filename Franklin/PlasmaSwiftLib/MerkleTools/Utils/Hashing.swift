//
//  Hashing.swift
//  MerkleTools
//
//  Created by Alexander Vlasov on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift

/// Variable-bit hashes using the Keccak hash function
/// - Returns: Encrypted data in Data format
public func keccak256(_ data: Data) -> Data {
    return data.sha3(.keccak256)
}

/// Hash function is some func with Data parameter that returns Data
public typealias TreeHashFunction = ((Data) -> Data)

/// Hasher protocol
public protocol Hasher {
    func hash(_ data: Data) -> Data
}

/// Tree hasher class for hashing some data
public class TreeHasher: Hasher {
    
    /// Hash some data
    /// - Parameter data: some data to hash
    /// - Returns: Encrypted data in Data format
    public func hash(_ data: Data) -> Data {
        return self.hashFunction(data)
    }
    
    /// Hash function
    public var hashFunction: TreeHashFunction
    
    /// Create TreeHasher object with some hash function
    /// - Parameter function: some hash function
    public init(_ function: @escaping TreeHashFunction) {
        self.hashFunction = function
    }
    
    /// Create TreeHasher object with Keccak hash function
    public init() {
        self.hashFunction = keccak256
    }
    
}
