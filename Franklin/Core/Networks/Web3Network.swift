//
//  Network.swift
//  DiveLane
//
//  Created by Антон Григорьев on 02/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import CoreData

protocol IWeb3Network {
    func select()
    func save() throws
}

public class Web3Network: IWeb3Network {
    public let id: Int64
    public let name: String
    public var endpoint: String
    public let isCustom: Bool
    
    private let userDefaults = UserDefaultKeys()
    
    public init(crModel: NetworkModel) throws {
        let id = crModel.id
        guard let endpoint = crModel.endpoint else {
            throw Errors.NetworkStorageErrors.cantGetNetwork
        }
        guard let name = crModel.name else {
            throw Errors.NetworkStorageErrors.cantGetNetwork
        }
        let isCustom = crModel.isCustom
        self.id = id
        self.name = name
        self.endpoint = endpoint
        self.isCustom = isCustom
    }
    
    public init(network: Web3Network) {
        self.id = network.id
        self.name = network.name
        self.endpoint = network.endpoint
        self.isCustom = network.isCustom
    }
    
    public init(id: Int64,
                name: String,
                endpoint: String,
                isCustom: Bool = true) {
        self.id = id
        self.name = name
        self.endpoint = endpoint
        self.isCustom = isCustom
    }
    
    public init(network: Networks) {
        self.id = Int64(network.chainID.description)!
        self.name = network.name
        switch network {
        case .Mainnet:
            self.endpoint = Web3.InfuraMainnetWeb3().provider.url.absoluteString
        case .Rinkeby:
            self.endpoint = Web3.InfuraRinkebyWeb3().provider.url.absoluteString
        case .Ropsten:
            self.endpoint = Web3.InfuraRopstenWeb3().provider.url.absoluteString
        default:
            self.endpoint =  Web3.InfuraMainnetWeb3().provider.url.absoluteString
        }
        self.isCustom = false
    }
    
    public func select() {
        userDefaults.setCurrentNetwork(self)
    }
    
    public func save() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "NetworkModel", into: context) as? NetworkModel else {
                error = Errors.NetworkStorageErrors.cantCreateNetwork
                group.leave()
                return
            }
            entity.id = self.id
            entity.name = self.name
            entity.endpoint = self.endpoint
            entity.isCustom = self.isCustom
            do {
                try context.save()
                group.leave()
            } catch let someErr {
                error = someErr
                group.leave()
            }
        }
        group.wait()
        if let resErr = error {
            throw resErr
        }
    }
    
    public func delete() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestNetwork: NSFetchRequest<NetworkModel> = NetworkModel.fetchRequest()
        requestNetwork.predicate = NSPredicate(format: "endpoint = %@", self.endpoint)
        do {
            let results = try ContainerCD.context.fetch(requestNetwork)
            guard let network = results.first else {
                error = Errors.WalletErrors.wrongWallet
                group.leave()
                return
            }
            ContainerCD.context.delete(network)
            try ContainerCD.context.save()
            group.leave()
        } catch let someErr {
            error = someErr
            group.leave()
        }
        group.wait()
        if let resErr = error {
            throw resErr
        }
    }
    
    public func getWeb() throws -> web3 {
        guard let url = URL(string: endpoint), let infura = Web3HttpProvider(url) else {
            throw Errors.NetworkErrors.wrongURL
        }
        let w3: web3 = web3(provider: infura)
        return w3
    }
    
    func isXDai() -> Bool {
        return self == XDaiNetwork()
    }
    
    func isMainnet() -> Bool {
        return self == Web3Network(network: .Mainnet)
    }
    
    func isRinkebi() -> Bool {
        return self == Web3Network(network: .Rinkeby)
    }
    
    func isRopsten() -> Bool {
        return self == Web3Network(network: .Ropsten)
    }
}
