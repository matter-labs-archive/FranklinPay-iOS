//
//  TokensService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

protocol ITokensService {
    func getFullTokensList(for searchString: String, completion: @escaping ([ERC20TokenModel]?) -> Void)
    func downloadAllAvailableTokensIfNeeded( completion: @escaping (Error?)-> Void)
}

class TokensService {
    
    let web3service = Web3SwiftService()
    
    let conversionService = FiatServiceImplementation.service
    
    public func getFullTokensList(for searchString: String, completion: @escaping ([ERC20TokenModel]?) -> Void)  {
        var tokensList: [ERC20TokenModel] = []
        DispatchQueue.global().async {
            let tokensFromCD = LocalDatabase().getTokensList(for: searchString)
            if let tokens = tokensFromCD {
                if tokens.count != 0 {
                    DispatchQueue.main.async {
                        for token in tokens {
                            let tokenModel = ERC20TokenModel(name: token.name,
                                                             address: token.address,
                                                             decimals: token.decimals,
                                                             symbol: token.symbol)
                            tokensList.append(tokenModel)
                        }
                        completion(tokensList)
                    }
                    
                } else {
                    self.getOnlineTokensList(with: searchString, completion: { (list) in
                        completion(list)
                    })
                }
            } else {
                self.getOnlineTokensList(with: searchString, completion: { (list) in
                    completion(list)
                })
            }
        }
        
    }
    
    
    private func name(for token: String, completion: @escaping (String?) -> Void) {
        let contract = web3service.contract(for: token)
        if let transaction = contract?.method("name", parameters: [AnyObject](), options: web3service.defaultOptions()) {
            DispatchQueue.global().async {
                let result = transaction.call(options: self.web3service.defaultOptions(), onBlock: "latest")
                DispatchQueue.main.async {
                    if let name = result.value?["0"] as? String, !name.isEmpty {
                        completion(name)
                    }
                    else {
                        completion(nil)
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
    
    private func symbol(for token: String, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.web3service.contract(for: token)
            let transaction = contract?.method("symbol", parameters: [AnyObject](), options: self.web3service.defaultOptions())
            let balance = transaction?.call(options: self.web3service.defaultOptions())
            DispatchQueue.main.async {
                if let symbol = balance?.value?["0"] as? String, !symbol.isEmpty  {
                    completion(symbol)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    private func decimals(for token: String, completion: @escaping (BigUInt?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let contract = self.web3service.contract(for: token)
            let transaction = contract?.method("decimals", parameters: [AnyObject](), options: self.web3service.defaultOptions())
            let bkxBalance = transaction?.call(options: self.web3service.defaultOptions())
            DispatchQueue.main.async {
                if let balance = bkxBalance?.value?["0"] as? BigUInt {
                    completion(balance)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    private func getOnlineTokensList(with address: String, completion: @escaping ([ERC20TokenModel]?) -> Void) {
        
        guard let _ = EthereumAddress(address) else {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            var name: String = ""
            self.name(for: address, completion: { (result) in
                if let localName = result {
                    name = localName
                } else {
                    name = ""
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            var decimals: BigUInt = BigUInt()
            self.decimals(for: address, completion: { (result) in
                if let localdecimals = result {
                    decimals = localdecimals
                } else {
                    decimals = ""
                }
                
            })
            
            dispatchGroup.enter()
            var symbol: String = ""
            self.symbol(for: address, completion: { (result) in
                if let localsymbol = result {
                    symbol = localsymbol
                } else {
                    symbol = ""
                }
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .main) {
                guard !name.isEmpty, !symbol.isEmpty else {
                    completion(nil)
                    return
                }
                completion([ERC20TokenModel(name: name,
                                            address: address,
                                            decimals: decimals.description,
                                            symbol: symbol)])
                
            }
        }
    }
    
    public func downloadAllAvailableTokensIfNeeded( completion: @escaping (Error?)-> Void) {
        
        guard let url = URL(string: URLs.urlDownloadTOkensList) else {
            completion(NetworkErrors.couldnotParseUrlString)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    if let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                        let dictsCount = jsonSerialized.count
                        var counter = 0
                        try jsonSerialized.forEach({ (dict) in
                            counter += 1
                            LocalDatabase().saveToken(from: dict, completion: { (error) in
                                if counter == dictsCount {
                                    completion(nil)
                                }
                            })
                        })
                    }
                }  catch  {
                    completion(error)
                }
            } else  {
                completion(error)
            }
        }
        task.resume()
    }
    
    func updateConversion(for token: ERC20TokenModel, completion: @escaping (Double?)->()) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.conversionService.updateConversionRate(for: token.symbol.uppercased()) { (rate) in
                completion(rate)
            }
        }
        
    }
    
}
