//
//  NetworksCoordinator.swift
//  Franklin
//
//  Created by Anton on 07/03/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift

public class NetworksCoordinator {
    private let networksService = NetworksService()
    
    func getNetworks() -> [TableNetwork] {
        let customNetworks = self.networksService.getAllCustomNetworks()
        let basicNetworks: [Networks] = [.Mainnet,
                                         .Rinkeby,
                                         .Ropsten]
        var web3networks: [Web3Network]
        let basicWeb3Nets = basicNetworks.map({
            Web3Network(network: $0)
        })
        web3networks = basicWeb3Nets
        let xdai = XDaiNetwork()
        web3networks.append(xdai)
        web3networks.append(contentsOf: customNetworks)
        
        let currentNetwork = CurrentNetwork.currentNetwork
        
        var networksArray = [TableNetwork]()
        for network in web3networks {
            let tableNetwork = TableNetwork(network: network,
                                            isSelected: (network == currentNetwork)
            )
            networksArray.append(tableNetwork)
        }
        return networksArray
    }
}
