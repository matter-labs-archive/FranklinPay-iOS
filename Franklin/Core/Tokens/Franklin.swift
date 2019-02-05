//
//  Franklin.swift
//  MatterWallet
//
//  Created by Anton Grigorev on 21/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class Franklin: ERC20Token {
    public init() {
        super.init(name: "Franklin",
                   address: "",
                   decimals: "18",
                   symbol: "FRN")
    }
}
