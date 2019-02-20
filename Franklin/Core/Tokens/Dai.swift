//
//  Dai.swift
//  Franklin
//
//  Created by Anton on 12/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class Dai: ERC20Token {
    public init() {
        super.init(name: "DAI",
                   address: "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359",
                   decimals: "18",
                   symbol: "DAI")
    }
}
