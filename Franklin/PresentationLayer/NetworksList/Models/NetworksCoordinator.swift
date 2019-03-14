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
        let customNetworks = self.networksService.getAllNetworks()
        let currentNetwork = CurrentNetwork.currentNetwork
        var networksArray = [TableNetwork]()
        for network in customNetworks {
            let tableNetwork = TableNetwork(network: network,
                                            isSelected: (network == currentNetwork)
            )
            networksArray.append(tableNetwork)
        }
        return networksArray
    }
}
