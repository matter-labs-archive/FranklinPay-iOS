//
//  ERC20Token.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public class ERC20TokenModel {
    var name: String
    var address: String
    var decimals: String
    var symbol: String

    init(token: ERC20Token) {
        self.name = token.name ?? ""
        self.address = token.address ?? ""
        self.decimals = token.decimals ?? ""
        self.symbol = token.symbol ?? ""
    }

    init(name: String,
         address: String,
         decimals: String,
         symbol: String) {
        self.name = name
        self.address = address
        self.decimals = decimals
        self.symbol = symbol
    }

    init(isEther: Bool) {
        self.name = isEther ? "Ether" : ""
        self.address = isEther ? "" : ""
        self.decimals = isEther ? "18" : "18"
        self.symbol = isEther ? "Eth" : ""
    }

    static func fromCoreData(crModel: ERC20Token) -> ERC20TokenModel {
        let model = ERC20TokenModel(name: crModel.name ?? "",
                address: crModel.address ?? "",
                decimals: crModel.decimals ?? "",
                symbol: crModel.symbol ?? "")
        return model
    }
}

extension ERC20TokenModel: Equatable {
    public static func ==(lhs: ERC20TokenModel, rhs: ERC20TokenModel) -> Bool {
        return lhs.name == rhs.name &&
            lhs.address == rhs.address &&
            lhs.decimals == rhs.decimals &&
            lhs.symbol == rhs.symbol
    }
}
