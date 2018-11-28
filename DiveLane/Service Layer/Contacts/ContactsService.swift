//
//  ContactsService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
private typealias PromiseResult = PromiseKit.Result

protocol IContactsService {
    func getFullContactsList(for searchString: String) throws -> [ContactModel]
}

class ContactsService: IContactsService {

    public func getFullContactsList(for searchString: String) throws -> [ContactModel] {
        return try self.getFullContactsList(for: searchString).wait()
    }
    
    private func getFullContactsList(for searchString: String) -> Promise<[ContactModel]> {
        let returnPromise = Promise<[ContactModel]> { (seal) in
            var contactsList: [ContactModel] = []
            guard let contacts = try? ContactsDatabase().getContactsList(for: searchString) else {
                seal.reject(StorageErrors.cantGetContact)
            }
            if !contacts.isEmpty {
                for contact in contacts {
                    let contactModel = ContactModel(address: contact.address,
                                                    name: contact.name)
                    contactsList.append(contactModel)
                }
                seal.fulfill(contactsList)
            } else {
                seal.reject(StorageErrors.noSuchContactInStorage)
            }
        }
        return returnPromise
    }

}
