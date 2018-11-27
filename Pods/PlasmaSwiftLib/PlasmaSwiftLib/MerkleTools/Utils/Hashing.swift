//
//  Hashing.swift
//  MerkleTools
//
//  Created by Alexander Vlasov on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift

func keccak256(_ data: Data) -> Data {
    return data.sha3(.keccak256)
}

public typealias TreeHashFunction = ((Data) -> Data)

public protocol Hasher {
    func hash(_ data: Data) -> Data
}

public class TreeHasher: Hasher {
    public func hash(_ data: Data) -> Data {
        return self.hashFunction(data)
    }
    
    public var hashFunction: TreeHashFunction
    
    public init(_ function: @escaping TreeHashFunction) {
        self.hashFunction = function
    }
    
    public init() {
        self.hashFunction = keccak256
    }
    
}
