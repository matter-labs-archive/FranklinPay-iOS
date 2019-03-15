//
//  NetworksCreator.swift
//  Franklin
//
//  Created by Anton on 15/03/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift

public class NetworkCreator {
    
    internal let walletsService = WalletsService()
    internal let appController = AppController()
    
    func formEndpointURLString(fromString string: String) throws -> URL {
        var urlString = string
        if !string.hasPrefix("https://") && !string.hasPrefix("http://") {
            urlString = "https://" + string
        }
        if !string.hasSuffix("/") {
            urlString += "/"
        }
        guard let url = URL(string: urlString) else {
            throw Errors.NetworkErrors.wrongURL
        }
        return url
    }
    
    func isNetworkPossible(network: Web3Network) -> Bool {
        if Web3.new(network.endpoint) != nil {
            return true
        } else {
            return false
        }
    }
    
    func addBaseTokenIfExists(forNetwork network: Web3Network) throws {
        guard let wallets = try? walletsService.getAllWallets() else {
            throw Errors.CommonErrors.unknownError
        }
        guard let web3 = Web3.new(network.endpoint) else {
            throw Errors.NetworkErrors.wrongURL
        }
        for wallet in wallets {
            if let _ = try? wallet.getETHbalance(web3instance: web3) {
                try appController.addEther(for: wallet, network: network)
            }
        }
    }
}
