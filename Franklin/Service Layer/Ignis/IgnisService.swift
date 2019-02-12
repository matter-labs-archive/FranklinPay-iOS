//
//  IgnisService.swift
//  Franklin
//
//  Created by Anton on 12/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress
import BigInt
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

public final class IgnisService {
    public init() {}
    
    private func request(url: URL,
                         data: Data?,
                         method: Method,
                         contentType: ContentType) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        request.httpMethod = method.rawValue
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        return request
    }
    
    var session: URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig,
                                 delegate: nil,
                                 delegateQueue: nil)
        return session
    }
    
    public func getID(for address: EthereumAddress) throws -> String {
        return try getIDPromise(for: address).wait()
    }
    
    public func getIDPromise(for address: EthereumAddress) -> Promise<String> {
        let returnPromise = Promise<String> { (seal) in
            let url = IgnisURLs.getID
            let json: [String: Any] = ["address": address.address]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            guard let request = request(url: url,
                                        data: jsonData,
                                        method: .get,
                                        contentType: .json) else {
                                            seal.reject(PlasmaErrors.NetErrors.cantCreateRequest)
                                            return
            }
            session.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let data = data, error == nil else {
                    seal.reject(PlasmaErrors.NetErrors.noData)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    seal.reject(PlasmaErrors.NetErrors.badResponse)
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    seal.reject(PlasmaErrors.NetErrors.badResponse)
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    if let id = responseJSON["id"] as? String {
                        seal.fulfill(id)
                    } else {
                        seal.reject(PlasmaErrors.StructureErrors.cantDecodeData)
                    }
                } else {
                    seal.reject(PlasmaErrors.StructureErrors.cantDecodeData)
                }
            }).resume()
        }
        return returnPromise
    }
    
    public func sendRawTX(transaction: SignedIgnisTransaction,
                          onTestnet: Bool = false) throws -> Bool {
        return try sendRawTXPromise(transaction: transaction, onTestnet: onTestnet).wait()
    }
    
    public func sendRawTXPromise(transaction: SignedIgnisTransaction,
                                 onTestnet: Bool = false) -> Promise<Bool> {
        let returnPromise = Promise<Bool> { (seal) in
            let json: [String: Any] = ["from":transaction.tx.from,
                                       "to":transaction.tx.to,
                                       "amount":transaction.tx.amount,
                                       "fee":transaction.tx.fee,
                                       "nonce":transaction.tx.nonce,
                                       "good_until_block":transaction.tx.goodUntilBlock,
                                       "signature":["r_x":transaction.r,
                                                    "r_y":transaction.v,
                                                    "s":transaction.s]
                                        ]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            let url = onTestnet ? IgnisURLs.sendRawTXTestnet : IgnisURLs.sendRawTXMainnet
            guard let request = request(url: url,
                                        data: jsonData,
                                        method: .post,
                                        contentType: .json) else {
                                            seal.reject(PlasmaErrors.NetErrors.cantCreateRequest)
                                            return
            }
            
            session.dataTask(with: request, completionHandler: { data, response, error in
                guard let data = data, error == nil else {
                    seal.reject(PlasmaErrors.NetErrors.noData)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    seal.reject(PlasmaErrors.NetErrors.badResponse)
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    seal.reject(PlasmaErrors.NetErrors.badResponse)
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    if let accepted = responseJSON["accepted"] as? Bool {
                        seal.fulfill(accepted)
                    } else if let reason = responseJSON["reason"] as? String {
                        print(reason)
                        seal.fulfill(false)
                    }
                } else {
                    seal.reject(PlasmaErrors.StructureErrors.cantDecodeData)
                }
            }).resume()
        }
        return returnPromise
    }
}

private enum Method: String {
    case post = "POST"
    case get = "GET"
}

private enum ContentType: String {
    case json = "application/json"
    case octet = "application/octet-stream"
}
