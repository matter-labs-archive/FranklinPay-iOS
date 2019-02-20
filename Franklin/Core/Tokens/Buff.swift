//
//  Buff.swift
//  Franklin
//
//  Created by Anton on 17/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class Buff: ERC20Token {
    public init() {
        super.init(name: "buffiDai",
                   address: "0x3e50bf6703fc132a94e4baff068db2055655f11b",
                   decimals: "18",
                   symbol: "BUFF")
    }
}
