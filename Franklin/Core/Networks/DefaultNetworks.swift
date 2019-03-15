//
//  XDaiNetwork.swift
//  Franklin
//
//  Created by Anton on 07/03/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

class XDaiNetwork: Web3Network {
    init() {
        super.init(id: 100,
                   name: "xDai",
                   endpoint: URL(string: "https://dai.poa.network/")!,
                   isCustom: false)
    }
}

class MainnetNetwork: Web3Network {
    init() {
        super.init(network: .Mainnet)
    }
}

class RinkebyNetwork: Web3Network {
    init() {
        super.init(network: .Rinkeby)
    }
}

class RopstenNetwork: Web3Network {
    init() {
        super.init(network: .Ropsten)
    }
}
