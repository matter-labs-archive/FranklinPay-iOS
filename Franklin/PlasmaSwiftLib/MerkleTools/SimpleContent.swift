//
//  SimpleContent.swift
//  MerkleTools
//
//  Created by Alexander Vlasov on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public struct SimpleContent: ContentProtocol {
    public func getHash(_ hasher: TreeHasher) -> Data {
        return hasher.hash(self.data)
    }
    
    public func isEqualTo(_ other: ContentProtocol) -> Bool {
        return self.data == other.data
    }
    
    public var data: Data
    public init(_ data: Data) {
        self.data = data
    }
}
