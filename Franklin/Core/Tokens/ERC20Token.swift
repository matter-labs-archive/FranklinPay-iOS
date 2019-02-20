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
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IERC20Token: IToken {
    func isEther() -> Bool
    func isFranklin() -> Bool
    func isDai() -> Bool
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
                throw Errors.TokenErrors.cantGetToken
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
            self.symbol = "ETH"
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
            self.address = "Plasma"
            self.decimals = "18"
            self.symbol = "ETH"
        } else {
            self.name = ""
            self.address = ""
            self.decimals = ""
            self.symbol = ""
        }
    }
    
    public init(dai: Bool = true) {
        if dai {
            self.name = "DAI"
            self.address = "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359"
            self.decimals = "18"
            self.symbol = "DAI"
        } else {
            self.name = ""
            self.address = ""
            self.decimals = ""
            self.symbol = ""
        }
    }
    
    public init(xdai: Bool = true) {
        if xdai {
            self.name = "xDai"
            self.address = "xDai"
            self.decimals = "18"
            self.symbol = "$"
        } else {
            self.name = ""
            self.address = ""
            self.decimals = ""
            self.symbol = ""
        }
    }
    
    public init(buff: Bool = true) {
        if buff {
            self.name = "buffiDai"
            self.address = "0x3e50bf6703fc132a94e4baff068db2055655f11b"
            self.decimals = "18"
            self.symbol = "BUFF"
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
    
    public func isDai() -> Bool {
        return self == Dai()
            ? true
            : false
    }
    
    public func isXDai() -> Bool {
        return self == XDai()
            ? true
            : false
    }
    
    public func isBuff() -> Bool {
        return self == Buff()
            ? true
            : false
    }
}
