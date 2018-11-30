//
//  FiatService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IRatesService {
    func updateConversionRate(for tokenName: String) throws -> Double
    func currentConversionRate(for tokenName: String) -> Double
}

public class RatesService: IRatesService {

    static let service = RatesService()
    public var conversionRates = [String: Double]()

    let urlFormat = URLs.pricesFromCryptocompare
    
    private func updateConversionRatePromise(for tokenName: String) -> Promise<Double> {
        let promiseResult = Promise<Double> { (seal) in
            let fullURLString = String(format: urlFormat, tokenName)
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
                            
                            if let conversionRate = json["USD"] as? Double {
                                self.conversionRates[tokenName] = conversionRate
                                seal.fulfill(conversionRate)
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

    public func updateConversionRate(for tokenName: String) throws -> Double  {
        return try self.updateConversionRatePromise(for: tokenName).wait()
    }

    public func currentConversionRate(for tokenName: String) -> Double {
        return conversionRates[tokenName] ?? 0
    }
}
