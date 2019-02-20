//
//  ERC20TokenRate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IERC20TokenRate {
    func updateRateAndChange() throws -> (rate: Double, change: Double)
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
