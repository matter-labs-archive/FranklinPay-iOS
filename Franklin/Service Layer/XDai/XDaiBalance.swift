//
//  BalanceJSON.swift
//  Franklin
//
//  Created by Anton on 16/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

struct BalanceXDAI: Codable {
    var id: UInt64
    var jsonrpc: String
    var method: String
    var params: [String]
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? UInt64 ?? 10
        self.jsonrpc = dictionary["id"] as? String ?? "2.0"
        self.method = dictionary["method"] as? String ?? "eth_getBalance"
        self.params = dictionary["params"] as? [String] ?? ["0x4fd693f57e63714591a07a73a4d7ad84e5ccde10", "latest"]
    }
}

extension BalanceXDAI {
    enum CodingKeys: String, CodingKey {
        case id
        case jsonrpc
        case method
        case params
    }
}
