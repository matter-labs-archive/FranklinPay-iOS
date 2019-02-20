//
//  XDai.swift
//  Franklin
//
//  Created by Anton on 16/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class XDai: ERC20Token {
    public init() {
        super.init(name: "xDai",
                   address: "xDai",
                   decimals: "18",
                   symbol: "$")
    }
}
