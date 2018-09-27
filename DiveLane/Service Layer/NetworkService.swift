//
//  NetworkService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

class CurrentWeb {

    static var _currentWeb: web3?

    class var currentWeb: web3? {
        get {

            if (_currentWeb == nil) {
                _currentWeb = Web3.InfuraMainnetWeb3()
            }
            return _currentWeb
        }

        set(web) {
            _currentWeb = web
        }
    }

}

class CurrentNetwork {

    static var _currentNetwork: Networks?

    class var currentNetwork: Networks? {
        get {

            if (_currentNetwork == nil) {
                _currentNetwork = Networks.Mainnet
            }
            return _currentNetwork
        }

        set(network) {

            _currentNetwork = network
        }
    }

    func getNetworkID() -> Int64 {
        return Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
    }
}
