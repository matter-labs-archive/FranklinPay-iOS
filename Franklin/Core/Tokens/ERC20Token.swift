//
//  ERC20Token.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt
import CoreData
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IERC20Token {
    func isEther() -> Bool
}

protocol IERC20TokenStorage {
    func saveIn(wallet: Wallet, network: Web3Network) throws
    func select(in wallet: Wallet, network: Web3Network) throws
    func saveRate(rate: Double, change24: Double) throws 
}

protocol IERC20TokenRate {
    func updateRateAndChange() throws -> (rate: Double, change: Double)
}

public class ERC20Token: IERC20Token {
    var name: String
    var address: String
    var decimals: String
    var symbol: String
    var rate: Double?
    var change24: Double?
    var walletAddress: String?
    var balance: String?
    var usdBalance: String?

    public init(crModel: ERC20TokenModel) throws {
        guard let name = crModel.name,
            let address = crModel.address,
            let decimals = crModel.decimals,
            let symbol = crModel.symbol else {
                throw Errors.StorageErrors.cantGetToken
        }
        let rate = crModel.rate
        let change24 = crModel.change24
        let walletAddress = crModel.walletAddress
        let balance = crModel.balance
        let usdBalance = crModel.usdBalance
        self.name = name
        self.address = address
        self.decimals = decimals
        self.symbol = symbol
        self.walletAddress = walletAddress
        self.balance = balance
        self.usdBalance = usdBalance
        self.rate = rate
        self.change24 = change24
    }
    
    public init(ether: Bool = true) {
        if ether {
            self.name = "Ether"
            self.address = ""
            self.decimals = "18"
            self.symbol = "Eth"
        } else {
            self.name = ""
            self.address = ""
            self.decimals = ""
            self.symbol = ""
        }
    }
    
    public init(franklin: Bool = true) {
        if franklin {
            self.name = "Franklin"
            self.address = ""
            self.decimals = "18"
            self.symbol = "FRN"
        } else {
            self.name = ""
            self.address = ""
            self.decimals = ""
            self.symbol = ""
        }
    }
    
    public init(token: ERC20Token) {
        self.name = token.name
        self.address = token.address
        self.decimals = token.decimals
        self.symbol = token.symbol
    }

    public init(name: String,
         address: String,
         decimals: String,
         symbol: String) {
        self.name = name
        self.address = address
        self.decimals = decimals
        self.symbol = symbol
    }
    
    public func isEther() -> Bool {
        return self == Ether()
            ? true
            : false
    }
    
    public func isFranklin() -> Bool {
        return self == Franklin()
            ? true
            : false
    }
}

extension ERC20Token: IERC20TokenStorage {
    
    public func saveIn(wallet: Wallet, network: Web3Network) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "ERC20TokenModel",
                                                                   into: context) as? ERC20TokenModel else {
                                                                    error = Errors.StorageErrors.cantCreateToken
                                                                    group.leave()
                                                                    return
            }
            entity.address = self.address
            entity.name = self.name
            entity.symbol = self.symbol
            entity.decimals = self.decimals
            entity.isAdded = true
            entity.walletAddress = wallet.address
            entity.networkId = network.id
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
    
    public func select(in wallet: Wallet, network: Web3Network) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        requestToken.predicate = NSPredicate(format:
            "networkId == %@ && isAdded == %@ && walletAddress == %@",
                                             NSNumber(value: network.id),
                                             NSNumber(value: true),
                                             NSString(string: wallet.address)
        )
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            for item in results {
                let isEqual = item.address == self.address
                item.isSelected = isEqual
            }
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
    
    public func saveRate(rate: Double, change24: Double) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestToken: NSFetchRequest<ERC20TokenModel> = ERC20TokenModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestToken)
            for item in results {
                if item.address == self.address {
                    item.rate = rate
                    item.change24 = change24
                }
            }
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
    
}

extension ERC20Token: IERC20TokenRate {
    public func updateRateAndChange() throws -> (rate: Double, change: Double) {
        return try self.updateRateAndChangePromise(for: self.symbol.uppercased()).wait()
    }
    
    private func updateRateAndChangePromise(for tokenName: String) -> Promise<(rate: Double, change: Double)> {
        let promiseResult = Promise<(rate: Double, change: Double)> { (seal) in
            let fullURLString = String(format: URLs.pricesFromCryptocompare,
                                       tokenName)
            guard let url = URL(string: fullURLString) else {
                seal.reject(Errors.NetworkErrors.wrongURL)
                return
            }
            let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                
                if let data = data {
                    do {
                        // Convert the data to JSON
                        let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        
                        if let json = jsonSerialized {
                            if let raw = json["RAW"] as? [String: Any],
                                let token = raw[tokenName] as? [String: Any],
                                let usd = token["USD"] as? [String: Any],
                                let conversionRate = usd["PRICE"] as? Double, let change24 = usd["CHANGEPCT24HOUR"] as? Double {
                                let roundedRate = conversionRate.rounded(toPlaces: 4)
                                self.rate = roundedRate
                                let roundedChange = change24.rounded(toPlaces: 4)
                                self.change24 = roundedChange
                                //try? self.saveRate(rate: roundedRate, change24: roundedChange)
                                seal.fulfill((conversionRate, change24))
                            } else {
                                seal.reject(Errors.NetworkErrors.wrongJSON)
                            }
                        }
                    } catch let error as NSError {
                        seal.reject(error)
                    }
                } else if let error = error {
                    seal.reject(error)
                }
            }
            task.resume()
        }
        return promiseResult
    }
}

extension ERC20Token: Equatable {
    public static func ==(lhs: ERC20Token, rhs: ERC20Token) -> Bool {
        return lhs.name == rhs.name &&
            lhs.address == rhs.address &&
            lhs.decimals == rhs.decimals &&
            lhs.symbol == rhs.symbol
    }
}
