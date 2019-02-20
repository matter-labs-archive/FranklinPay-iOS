//
//  Web3NetworkEquatable.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

extension Web3Network: Equatable {
    public static func ==(lhs: Web3Network, rhs: Web3Network) -> Bool {
        return lhs.id == rhs.id
    }
}
