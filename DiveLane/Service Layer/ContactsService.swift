//
//  ContactsService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import struct BigInt.BigUInt

protocol IContactsService {
    func getFullContactsList(for searchString: String, completion: @escaping ([ContactModel]?) -> Void)
}

class ContactsService {

    public func getFullContactsList(for searchString: String, completion: @escaping ([ContactModel]?) -> Void) {
        var contactsList: [ContactModel] = []
        DispatchQueue.global().async {
            let contactsFromCD = ContactsDatabase().getContactsList(for: searchString)
            if let contacts = contactsFromCD {
                if contacts.count != 0 {
                    DispatchQueue.main.async {
                        for contact in contacts {
                            let contactModel = ContactModel(address: contact.address,
                                                            name: contact.name)
                            contactsList.append(contactModel)
                        }
                        completion(contactsList)
                    }
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }

    }

}
