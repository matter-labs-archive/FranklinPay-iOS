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
    func saveAsCustom()
}

public class Web3Network {
    public let id: Int64
    public let name: String
    
    private let userDefaults = UserDefaultKeys()
    
    public init(crModel: NetworkModel) throws {
        let id = crModel.id
        guard let name = crModel.name else {
                throw Errors.StorageErrors.cantCreateNetwork
        }
        self.id = id
        self.name = name
    }
    
    public init(network: Web3Network) {
        self.id = network.id
        self.name = network.name
    }
    
    public init(id: Int64,
                name: String) {
        self.id = id
        self.name = name
    }
    
    public init(network: Networks) {
        self.id = Int64(network.chainID.description)!
        self.name = network.name
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
                error = Errors.StorageErrors.cantCreateNetwork
                group.leave()
                return
            }
            entity.id = self.id
            entity.name = self.name
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
}

extension Web3Network: Equatable {
    public static func ==(lhs: Web3Network, rhs: Web3Network) -> Bool {
        return lhs.id == rhs.id
    }
}
