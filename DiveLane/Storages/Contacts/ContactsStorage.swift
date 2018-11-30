//
//  ContactsDatabase.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

import CoreData
import BigInt

protocol IContactsStorage {
    func getContact(address: String) throws -> ContactModel
    func saveContact(contact: ContactModel) throws
    func getAllContacts() throws -> [ContactModel]
    func deleteContact(contact: ContactModel) throws
    func getContactsList(for searchingString: String) throws -> [ContactModel]
}

public class ContactsStorage: IContactsStorage {

    lazy var container: NSPersistentContainer = NSPersistentContainer(name: "CoreDataModel")
    private lazy var mainContext = self.container.viewContext

    init() {
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }

    public func getContact(address: String) throws -> ContactModel {
        let requestContact: NSFetchRequest<Contact> = Contact.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address = %@", address)
        do {
            let results = try mainContext.fetch(requestContact)
            guard let result = results.first else {
                throw Errors.StorageErrors.cantGetContact
            }
            return ContactModel.fromCoreData(crModel: result)
        } catch let error{
            throw error
        }
    }

    public func getAllContacts() throws -> [ContactModel] {
        let requestContacts: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            let results = try mainContext.fetch(requestContacts)
            return results.map {
                return ContactModel.fromCoreData(crModel: $0)
            }
        } catch let error{
            throw error
        }
    }

    public func saveContact(contact: ContactModel) throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        container.performBackgroundTask { (context) in
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
            let results = try mainContext.fetch(requestContact)
            guard let wallet = results.first else {
                error = Errors.StorageErrors.noSuchContactInStorage
                group.leave()
                return
            }
            mainContext.delete(wallet)
            try mainContext.save()
            group.leave()
        } catch let someErr{
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
            let results = try mainContext.fetch(requestContact)
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
