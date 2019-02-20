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
    
    public class var currentWeb: web3? {
        get {
            let w3: web3
            switch self.currentNetwork.id {
            case 1:
                w3 = Web3.InfuraMainnetWeb3()
            case 4:
                w3 = Web3.InfuraRinkebyWeb3()
            case 3:
                w3 = Web3.InfuraRopstenWeb3()
            case 100:
                let url = URL(string: "https://dai.poa.network")!
                let infura = Web3HttpProvider(url, network: nil, keystoreManager: nil)!
                w3 = web3(provider: infura)
            default:
                return nil
            }
            return w3
        }
    }
    
    func isXDai() -> Bool {
        return CurrentNetwork.currentNetwork.id == 100
    }
}

extension InfuraProvider {
    
}
