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
import CoreData
private typealias PromiseResult = PromiseKit.Result

protocol IContactsService {
    func getFullContactsList(for searchString: String) throws -> [ContactModel]
    func getContact(address: String) throws -> ContactModel
    func saveContact(contact: ContactModel) throws
    func getAllContacts() throws -> [ContactModel]
    func deleteContact(contact: ContactModel) throws
    func getContactsList(for searchingString: String) throws -> [ContactModel]
}

public class ContactsService: IContactsService {

    public func getFullContactsList(for searchString: String) throws -> [ContactModel] {
        return try self.getFullContactsList(for: searchString).wait()
    }
    
    private func getFullContactsList(for searchString: String) -> Promise<[ContactModel]> {
        let returnPromise = Promise<[ContactModel]> { (seal) in
            var contactsList: [ContactModel] = []
            guard let contacts = try? ContactsService().getContactsList(for: searchString) else {
                seal.reject(Errors.StorageErrors.cantGetContact)
                return
            }
            if !contacts.isEmpty {
                for contact in contacts {
                    let contactModel = ContactModel(address: contact.address,
                                                    name: contact.name)
                    contactsList.append(contactModel)
                }
                seal.fulfill(contactsList)
            } else {
                seal.reject(Errors.StorageErrors.noSuchContactInStorage)
            }
        }
        return returnPromise
    }
    
    public func getContact(address: String) throws -> ContactModel {
        let requestContact: NSFetchRequest<Contact> = Contact.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address = %@", address)
        do {
            let results = try ContainerCD.context.fetch(requestContact)
            guard let result = results.first else {
                throw Errors.StorageErrors.cantGetContact
            }
            return ContactModel.fromCoreData(crModel: result)
        } catch let error {
            throw error
        }
    }
    
    public func getAllContacts() throws -> [ContactModel] {
        let requestContacts: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            let results = try ContainerCD.context.fetch(requestContacts)
            return results.map {
                return ContactModel.fromCoreData(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }
    
    public func saveContact(contact: ContactModel) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as? Contact else {
                error = Errors.StorageErrors.cantCreateContact
                group.leave()
                return
            }
            entity.address = contact.address
            entity.name = contact.name
            do {
                try context.save()
                group.leave()
            } catch let someErr {
                error = someErr
                group.leave()
            }
        }
        group.wait()
        if let resErr = error {
            throw resErr
        }
    }
    
    public func deleteContact(contact: ContactModel) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestContact: NSFetchRequest<Contact> = Contact.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address CONTAINS[c] %@ || name CONTAINS[c] %@",
                                               contact.address,
                                               contact.name)
        do {
            let results = try ContainerCD.context.fetch(requestContact)
            guard let wallet = results.first else {
                error = Errors.StorageErrors.noSuchContactInStorage
                group.leave()
                return
            }
            ContainerCD.context.delete(wallet)
            try ContainerCD.context.save()
            group.leave()
        } catch let someErr {
            error = someErr
            group.leave()
        }
        group.wait()
        if let resErr = error {
            throw resErr
        }
    }
    
    public func getContactsList(for searchingString: String) throws -> [ContactModel] {
        let requestContact: NSFetchRequest<Contact> = Contact.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address CONTAINS[c] %@ || name CONTAINS[c] %@",
                                               searchingString,
                                               searchingString)
        do {
            let results = try ContainerCD.context.fetch(requestContact)
            return results.map {
                return ContactModel.fromCoreData(crModel: $0)
            }
        } catch let error {
            throw error
        }
    }

}

enum ContactsDataBaseError: Error {
    case noSuchContactInStorage
    case problemsWithInsertingNewEntity
}
