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
    func getAllCustomNetworks() throws -> [Web3Network]
}

public class NetworksService: INetworksService {
    
    private let userDefault = UserDefaultKeys()
    
    public func getAllCustomNetworks() throws -> [Web3Network] {
        let requestNetwork: NSFetchRequest<NetworkModel> = NetworkModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestNetwork)
            return try results.map {
                return try Web3Network(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    public func getSelectedNetwork() throws -> Web3Network {
        guard let networkFromUD = userDefault.getCurrentNetwork() else {
            throw Errors.StorageErrors.cantSelectNetwork
        }
        guard let id = networkFromUD["id"] as? Int64 else {
            throw Errors.StorageErrors.cantSelectNetwork
        }
        guard let name = networkFromUD["name"] as? String else {
            throw Errors.StorageErrors.cantSelectNetwork
        }
        let network = Web3Network(id: id, name: name)
        return network
    }
}
