//
//  KeyWallet.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

struct KeyWalletModel {
    let address: String
    let data: Data?
    let name: String
    
    static func fromCoreData(crModel: KeyWallet?) -> KeyWalletModel? {
        guard let crModel = crModel else {
            return nil
        }
        let model = KeyWalletModel(address: crModel.address ?? "",
                                   data: crModel.data,
                                   name: crModel.name ?? "")
        return model
    }
}
