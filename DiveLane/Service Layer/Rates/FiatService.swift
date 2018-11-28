//
//  FiatService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IRatesService {
    func updateConversionRate(for tokenName: String) throws -> Double
    func currentConversionRate(for tokenName: String) -> Double
}

class RatesService: IRatesService {

    static let service = RatesService()
    public var conversionRates = [String: Double]()

    let urlFormat = URLs.pricesFromCryptocompare
    
    private func updateConversionRatePromise(for tokenName: String) -> Promise<Double> {
        let promiseResult = Promise<Double> { (seal) in
            let fullURLString = String(format: urlFormat, tokenName)
            guard let url = URL(string: fullURLString) else {
                seal.reject(NetworkErrors.wrongURL)
                return
            }
            Alamofire.request(url)
                .responseJSON { response in
                    if let error = response.result.error {
                        seal.reject(error)
                        return
                    }
                    guard response.data != nil else {
                        seal.reject(NetworkErrors.noData)
                        return
                    }
                    guard let value = response.result.value as? [String: Any],
                        let conversionRate = value["USD"] as? Double else {
                            seal.reject(NetworkErrors.wrongJSON)
                            return
                    }
                    self.conversionRates[tokenName] = conversionRate
                    seal.fulfill(conversionRate)
            }
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
