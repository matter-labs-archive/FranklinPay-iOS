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
    func saveAsCustom() throws
}

public class Web3Network: IWeb3Network {
    public let id: Int64
    public let name: String
    public var endpoint: String?
    
    private let userDefaults = UserDefaultKeys()
    
    public init(crModel: NetworkModel) throws {
        let id = crModel.id
        let endpoint = crModel.endpoint
        guard let name = crModel.name else {
                throw Errors.NetworkStorageErrors.cantGetNetwork
        }
        self.id = id
        self.name = name
        self.endpoint = endpoint
    }
    
    public init(network: Web3Network) {
        self.id = network.id
        self.name = network.name
        self.endpoint = network.endpoint
    }
    
    public init(id: Int64,
                name: String,
                endpoint: String? = nil) {
        self.id = id
        self.name = name
        self.endpoint = endpoint
    }
    
    public init(network: Networks, endpoint: String? = nil) {
        self.id = Int64(network.chainID.description)!
        self.name = network.name
        if endpoint != nil {
            self.endpoint = endpoint
            return
        }
        switch network.chainID {
        case 1:
            self.endpoint = Web3.InfuraMainnetWeb3().provider.url.absoluteString
        case 4:
            self.endpoint = Web3.InfuraRinkebyWeb3().provider.url.absoluteString
        case 3:
            self.endpoint = Web3.InfuraRopstenWeb3().provider.url.absoluteString
        default:
            self.endpoint = nil
        }
    }
    
    public func select() {
        userDefaults.setCurrentNetwork(self)
    }
    
    public func saveAsCustom() throws {
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
    
    public func getWeb() -> web3? {
        let w3: web3
        switch self.id {
        case 1:
            w3 = Web3.InfuraMainnetWeb3()
        case 4:
            w3 = Web3.InfuraRinkebyWeb3()
        case 3:
            w3 = Web3.InfuraRopstenWeb3()
        case 100:
            let url = URL(string: "https://dai.poa.network")!
            let infura = Web3HttpProvider(url)!
            w3 = web3(provider: infura)
        default:
            if endpoint != nil {
                let url = URL(string: self.endpoint!)!
                let infura = Web3HttpProvider(url)!
                w3 = web3(provider: infura)
                return w3
            }
            return nil
        }
        return w3
    }
    
    func isXDai() -> Bool {
        return self.id == 100
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
