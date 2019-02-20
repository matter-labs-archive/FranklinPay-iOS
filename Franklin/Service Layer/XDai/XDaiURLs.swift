//
//  XDaiURLs.swift
//  Franklin
//
//  Created by Anton on 16/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation

public class XDaiURLs {
    
    public init() {}
    
    static let baseURLString: String = "https://blockscout.com/poa/dai/api"
    
    func balance(address: String) throws -> URL {
        let string = XDaiURLs.baseURLString + "?module=account&action=balance&address=" + address
        guard let url = URL(string: string) else {
            throw Errors.NetworkErrors.wrongURL
        }
        return url
    }
    
    func transactions(address: String) throws -> URL {
        let string = XDaiURLs.baseURLString + "?module=account&action=txlist&address=" + address
        guard let url = URL(string: string) else {
            throw Errors.NetworkErrors.wrongURL
        }
        return url
    }
    
    func tokens(address: String) throws -> URL {
        let string = XDaiURLs.baseURLString + "?module=account&action=tokenlist&address=" + address
        guard let url = URL(string: string) else {
            throw Errors.NetworkErrors.wrongURL
        }
        return url
    }
}
