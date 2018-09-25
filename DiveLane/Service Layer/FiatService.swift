//
//  FiatService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

protocol FiatService {
    
    func updateConversionRate(for tokenName: String,completion: @escaping (Double) -> Void)
    
    func currentConversionRate(for tokenName: String) -> Double
    
}


class FiatServiceImplementation: FiatService {
    
    static let service = FiatServiceImplementation()
    var conversionRates = [String: Double]()
    
    let urlFormat = "https://min-api.cryptocompare.com/data/price?fsym=%@&tsyms=USD"
    
    func updateConversionRate(for tokenName: String, completion: @escaping (Double) -> Void) {
        
        let fullURLString = String(format: urlFormat, tokenName)
        
        guard let url = URL(string: fullURLString) else {
            completion(0)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    
                    if let json = jsonSerialized {
                        
                        if let conversionRate = json["USD"] as? Double {
                            DispatchQueue.main.async {
                                self.conversionRates[tokenName] = conversionRate
                                completion(conversionRate)
                            }
                        } else {
                            print("Can't convert to Double")
                            DispatchQueue.main.async {
                                completion(0)
                            }
                        }
                    }
                }  catch let error as NSError {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        completion(0)
                    }
                }
            } else if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(0)
                }
            }
        }
        
        task.resume()
    }
    
    func currentConversionRate(for tokenName: String) -> Double {
        return conversionRates[tokenName] ?? 0
    }
}
