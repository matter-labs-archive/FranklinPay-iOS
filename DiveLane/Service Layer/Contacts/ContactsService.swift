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
import CoreData

protocol IContactsService {
    func getFullContactsList(for searchString: String) throws -> [Contact]
}

protocol IContactsStorage {
    func getContact(address: String) throws -> Contact
    func getAllContacts() throws -> [Contact]
    func getContactsList(for searchingString: String) throws -> [Contact]
}

public class ContactsService: IContactsService {

    public func getFullContactsList(for searchString: String) throws -> [Contact] {
        return try self.getFullContactsList(for: searchString).wait()
    }
    
    private func getFullContactsList(for searchString: String) -> Promise<[Contact]> {
        let returnPromise = Promise<[Contact]> { (seal) in
            var contactsList: [Contact] = []
            guard let contacts = try? self.getContactsList(for: searchString) else {
                seal.reject(Errors.StorageErrors.cantGetContact)
                return
            }
            if !contacts.isEmpty {
                for contact in contacts {
                    let contactModel = Contact(address: contact.address,
                                               name: contact.name)
                    contactsList.append(contactModel)
                }
                seal.fulfill(contactsList)
            } else {
                seal.reject(Errors.StorageErrors.wrongContact)
            }
        }
        return returnPromise
    }
}

extension ContactsService: IContactsStorage {
    public func getContact(address: String) throws -> Contact {
        let requestContact: NSFetchRequest<ContactModel> = ContactModel.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address = %@", address)
        do {
            let results = try ContainerCD.context.fetch(requestContact)
            guard let result = results.first else {
                throw Errors.StorageErrors.cantGetContact
            }
            return try Contact(crModel: result)
        } catch let error {
            throw error
        }
    }
    
    public func getAllContacts() throws -> [Contact] {
        let requestContacts: NSFetchRequest<ContactModel> = ContactModel.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestContacts)
            return try results.map {
                return try Contact(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    public func getContactsList(for searchingString: String) throws -> [Contact] {
        let requestContact: NSFetchRequest<ContactModel> = ContactModel.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address CONTAINS[c] %@ || name CONTAINS[c] %@",
                                               searchingString,
                                               searchingString)
        do {
            let results = try ContainerCD.context.fetch(requestContact)
            return try results.map {
                return try Contact(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
}
