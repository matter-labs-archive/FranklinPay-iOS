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
        super.init(id: 100, name: "xDai", endpoint: "https://dai.poa.network")
    }
}
