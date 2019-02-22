//
//  NetworkService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt

public class CurrentNetwork {

    private static var _currentNetwork: Web3Network?

    public class var currentNetwork: Web3Network {
        get {
            if let net = _currentNetwork {
                return net
            } else {
                if let selectedNetwork = try? NetworksService().getSelectedNetwork() {
                    _currentNetwork = selectedNetwork
                    return selectedNetwork
                }
                //let xdai = Web3Network(id: 100, name: "xDai")
                let mainnet = Web3Network(network: Networks.Mainnet)
                mainnet.select()
                _currentNetwork = mainnet
                return mainnet
            }
        }

        set(network) {
            network.select()
            _currentNetwork = network
        }
    }
}

extension InfuraProvider {
    
}
