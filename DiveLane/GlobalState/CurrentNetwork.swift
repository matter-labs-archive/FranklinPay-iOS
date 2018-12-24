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

    private static var _currentNetwork: Networks?
    private static var _currentWeb: web3?

    public class var currentNetwork: Networks {
        get {
            if let net = _currentNetwork {
                return net
            } else {
                _currentNetwork = Networks.Mainnet
                return Networks.Mainnet
            }
        }

        set(network) {
            _currentNetwork = network
        }
    }
    
    public class var currentWeb: web3 {
        get {
            if let web = _currentWeb {
                return web
            } else {
                _currentWeb = Web3.InfuraMainnetWeb3()
                return Web3.InfuraMainnetWeb3()
            }
        }
        
        set(web) {
            _currentWeb = web
        }
    }
    
    public func getProvider() -> Web3Provider {
        let provider = CurrentNetwork.currentWeb.provider
        return provider
    }

    public func getNetworkID() -> Int64 {
        let chainID = Int64(CurrentNetwork.currentNetwork.chainID)
        return chainID
    }
}
