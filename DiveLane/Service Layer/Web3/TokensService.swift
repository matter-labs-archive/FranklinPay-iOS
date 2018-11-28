//
//  TokensService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 18/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Alamofire
import BigInt
import PromiseKit
import EthereumAddress
import Web3swift
private typealias PromiseResult = PromiseKit.Result

protocol ITokensService {
    func getFullTokensList(for searchString: String) throws -> [ERC20TokenModel]
    func downloadAllAvailableTokensIfNeeded() throws
    func updateConversion(for token: ERC20TokenModel) throws -> Double
}

class TokensService {

    let web3service = Web3Service()
    let ratesService = RatesService.service
    
    public func getFullTokensList(for searchString: String) throws -> [ERC20TokenModel] {
        return try self.getFullTokensList(for: searchString).wait()
    }
    
    private func getFullTokensList(for searchString: String) -> Promise<[ERC20TokenModel]> {
        let returnPromise = Promise<[ERC20TokenModel]> { (seal) in
            var tokensList: [ERC20TokenModel] = []
            let tokens = TokensStorage().getTokensList(for: searchString)
            if !tokens.isEmpty {
                for token in tokens {
                    let tokenModel = ERC20TokenModel(name: token.name,
                                                     address: token.address,
                                                     decimals: token.decimals,
                                                     symbol: token.symbol)
                    tokensList.append(tokenModel)
                }
                seal.fulfill(tokensList)
            } else {
                guard let token = try? self.getTokenFromNet(with: searchString) else {
                    seal.reject(Web3Error.processingError(desc: "No token from net"))
                }
                seal.fulfill([token])
            }
        }
        return returnPromise
    }

    private func name(for tokenAddress: String) throws -> String {
        do {
            let contract = try web3service.contract(for: tokenAddress)
            let options = web3service.defaultOptions()
            guard let transaction = contract.read("name", parameters: [AnyObject](), extraData: Data(), transactionOptions: options) else {
                throw Web3Error.transactionSerializationError
            }
            let result = try transaction.call(transactionOptions: options)
            guard let name = result["0"] as? String, !name.isEmpty else {
                throw Web3Error.dataError
            }
            return name
        } catch let error {
            throw error
        }
    }

    private func symbol(for tokenAddress: String) throws -> String {
        do {
            let contract = try web3service.contract(for: tokenAddress)
            let options = web3service.defaultOptions()
            guard let transaction = contract.read("symbol", parameters: [AnyObject](), extraData: Data(), transactionOptions: options) else {
                throw Web3Error.transactionSerializationError
            }
            let result = try transaction.call(transactionOptions: options)
            guard let symbol = result["0"] as? String, !symbol.isEmpty else {
                throw Web3Error.dataError
            }
            return symbol
        } catch let error {
            throw error
        }
    }

    private func decimals(for tokenAddress: String) throws -> BigUInt {
        do {
            let contract = try web3service.contract(for: tokenAddress)
            let options = web3service.defaultOptions()
            guard let transaction = contract.read("decimals", parameters: [AnyObject](), extraData: Data(), transactionOptions: options) else {
                throw Web3Error.transactionSerializationError
            }
            let result = try transaction.call(transactionOptions: options)
            guard let decimals = result["0"] as? BigUInt else {
                throw Web3Error.dataError
            }
            return decimals
        } catch let error {
            throw error
        }
    }

    private func getTokenFromNet(with address: String) throws -> ERC20TokenModel {

        guard EthereumAddress(address) != nil else {
            throw Web3Error.inputError(desc: "Wrong address")
        }

        let name = try self.name(for: address)
        let decimals = try self.decimals(for: address)
        let symbol = try self.symbol(for: address)
        
        guard !name.isEmpty, !symbol.isEmpty else {
            throw Web3Error.dataError
        }
        return ERC20TokenModel(name: name,
                               address: address,
                               decimals: decimals.description,
                               symbol: symbol)
    }
    
    public func downloadAllAvailableTokensIfNeeded() throws -> OperationResult {
        return try self.downloadAllAvailableTokensIfNeeded().wait()
    }

    private func downloadAllAvailableTokensIfNeeded() -> Promise<OperationResult> {
        let promiseResult = Promise<OperationResult> { (seal) in
            guard let url = URL(string: URLs.downloadTokensList) else {
                seal.fulfill(.error(NetworkErrors.wrongURL))
                return
            }
            Alamofire.request(url).responseJSON { response in
                if let error = response.result.error {
                    seal.reject(error)
                    return
                }
                guard response.data != nil else {
                    seal.reject(NetworkErrors.noData)
                    return
                }
                guard let value = response.result.value as? [[String: Any]] else {
                    seal.reject(NetworkErrors.wrongJSON)
                    return
                }
                let dictsCount = value.count
                var counter = 0
                value.forEach({ (dict) in
                    counter += 1
                    let _ = TokensStorage().saveCustomToken(from: dict)
                    if counter == dictsCount {
                        seal.fulfill(.success)
                    }
                })
            }
        }
        return promiseResult
    }

    public func updateConversion(for token: ERC20TokenModel) throws -> Double {
        return try self.ratesService.updateConversionRate(for: token.symbol.uppercased())
    }
}
