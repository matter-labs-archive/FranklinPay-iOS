//
//  KeyWallet.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public struct KeyWalletModel {
    let address: String
    let data: Data?
    let name: String
    let isHD: Bool

    public static func fromCoreData(crModel: KeyWallet) -> KeyWalletModel {
        let model = KeyWalletModel(address: crModel.address ?? "",
                data: crModel.data,
                name: crModel.name ?? "",
                isHD: crModel.isHD)
        return model
    }
}

extension KeyWalletModel: Equatable {
    public static func ==(lhs: KeyWalletModel, rhs: KeyWalletModel) -> Bool {
        return lhs.address == rhs.address
    }
}

public struct HDKey {
    let name: String?
    let address: String
}
