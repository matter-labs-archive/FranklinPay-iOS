//
//  ContactModel.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public class Contact {
    let address: String
    let name: String
    
    public init(crModel: ContactModel) throws {
        guard let address = crModel.address,
            let name = crModel.name else {
                throw Errors.ContactErrors.cantCreateContact
        }
        self.address = address
        self.name = name
    }

    public init(contact: Contact) {
        self.address = contact.address
        self.name = contact.name
    }
    
    public init(address: String, name: String) {
        self.address = address
        self.name = name
    }
}
