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
    private static var _currentWeb: web3?

    public class var currentNetwork: Web3Network? {
        get {
            if let net = _currentNetwork {
                return net
            } else {
                if let selectedNetwork = try? NetworksService().getSelectedNetwork() {
                    _currentNetwork = selectedNetwork
                    return selectedNetwork
                } else {
                    let mainnet = Web3Network(network: Networks.Mainnet)
                    mainnet.select()
                    _currentNetwork = mainnet
                    return mainnet
                }
                _currentNetwork = Web3Network(network: Networks.Mainnet)
                return Web3Network(network: Networks.Mainnet)
            }
        }

        set(network) {
            if let currentNetwork = network {
                currentNetwork.select()
                _currentNetwork = network
            }
        }
    }
    
    public class var currentWeb: web3? {
        get {
            if let web = _currentWeb {
                return web
            } else {
                guard let network = self.currentNetwork else {
                    return nil
                }
                let web3: web3
                switch network.name {
                case "mainnet":
                    web3 = Web3.InfuraMainnetWeb3()
                case "rinkeby":
                    web3 = Web3.InfuraRinkebyWeb3()
                case "ropsten":
                    web3 = Web3.InfuraRopstenWeb3()
                default:
                    return nil
                }
                _currentWeb = web3
                return web3
            }
        }
    }
}
