//
//  ContactModel.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

struct ContactModel {
    let address: String
    let name: String

    static func fromCoreData(crModel: Contact) -> ContactModel {
        let model = ContactModel(address: crModel.address ?? "",
                                   name: crModel.name ?? "")
        return model
    }
}

extension ContactModel: Equatable {
    static func ==(lhs: ContactModel, rhs: ContactModel) -> Bool {
        return lhs.address == rhs.address
    }
}
