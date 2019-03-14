//
//  NetworksService.swift
//  DiveLane
//
//  Created by Антон Григорьев on 02/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt
import EthereumAddress
import CoreData

protocol INetworksService {
    func getSelectedNetwork() throws -> Web3Network
    func getAllNetworks() -> [Web3Network]
    func getHighestID() -> Int64
    func isNetworkExists(network: Web3Network) -> Bool
}

public class NetworksService: INetworksService {
    
    private let userDefault = UserDefaultKeys()
    
    public func getAllNetworks() -> [Web3Network] {
        let requestNetwork: NSFetchRequest<NetworkModel> = NetworkModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestNetwork)
            return try results.map {
                return try Web3Network(crModel: $0)
            }
        } catch {
            return []
        }
    }
    
    public func getSelectedNetwork() throws -> Web3Network {
        guard let networkFromUD = userDefault.getCurrentNetwork() else {
            throw Errors.NetworkStorageErrors.cantSelectNetwork
        }
        guard let id = networkFromUD["id"] as? Int64 else {
            throw Errors.CommonErrors.wrongType
        }
        guard let name = networkFromUD["name"] as? String else {
            throw Errors.CommonErrors.wrongType
        }
        guard let endpoint = networkFromUD["endpoint"] as? String else {
            throw Errors.CommonErrors.wrongType
        }
        let network = Web3Network(id: id, name: name, endpoint: endpoint)
        return network
    }
    
    public func isNetworkExists(network: Web3Network) -> Bool {
        let networks = self.getAllNetworks()
        for net in networks {
            if net.endpoint == network.endpoint {
                return true
            }
        }
        return false
    }
    
    public func getHighestID() -> Int64 {
        let requestNetwork: NSFetchRequest<NetworkModel> = NetworkModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestNetwork)
            let nets = try results.map {
                return try Web3Network(crModel: $0)
            }
            var id: Int64 = 100
            for net in nets {
                if net.id > id {
                    id = Int64(net.id)
                }
            }
            return id
        } catch {
            return 100
        }
    }
}
