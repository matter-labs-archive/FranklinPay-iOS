//
//  ContactsDatabase.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

import CoreData
import struct BigInt.BigUInt

protocol IContactsDatabase {
    func getContact(address: String) -> ContactModel?
    func saveContact(contact: ContactModel?, completion: @escaping (Error?) -> Void)
    func getAllContacts() -> [ContactModel]
    func deleteContact(contact: ContactModel, completion: @escaping (Error?) -> Void)
    func getContactsList(for searchingString: String) -> [ContactModel]?
}

class ContactsDatabase: IContactsDatabase {

    lazy var container: NSPersistentContainer = NSPersistentContainer(name: "CoreDataModel")
    private lazy var mainContext = self.container.viewContext

    init() {
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }

    public func getContact(address: String) -> ContactModel? {
        let requestContact: NSFetchRequest<Contact> = Contact.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address = %@", address)
        do {
            let results = try mainContext.fetch(requestContact)
            guard let result = results.first else {
                return nil
            }
            return ContactModel.fromCoreData(crModel: result)

        } catch {
            print(error)
            return nil
        }

    }

    public func getAllContacts() -> [ContactModel] {
        let requestContacts: NSFetchRequest<Contact> = Contact.fetchRequest()
        do {
            let results = try mainContext.fetch(requestContacts)
            return results.map {
                return ContactModel.fromCoreData(crModel: $0)
            }

        } catch {
            print(error)
            return []
        }
    }

    public func saveContact(contact: ContactModel?, completion: @escaping (Error?) -> Void) {
        container.performBackgroundTask { (context) in
            guard let contact = contact else {
                return
            }
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: context) as? Contact else {
                return
            }
            entity.address = contact.address
            entity.name = contact.name
            do {
                try context.save()
                DispatchQueue.main.async {
                    completion(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        }
    }

    public func deleteContact(contact: ContactModel, completion: @escaping (Error?) -> Void) {

        let requestContact: NSFetchRequest<Contact> = Contact.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address CONTAINS[c] %@ || name CONTAINS[c] %@",
                                               contact.address,
                                               contact.name)
        do {
            let results = try mainContext.fetch(requestContact)
            guard let item = results.first else {
                completion(ContactsDataBaseError.noSuchContactInStorage)
                return
            }
            mainContext.delete(item)
            try mainContext.save()
            completion(nil)

        } catch {
            completion(error)
        }
    }

    public func getContactsList(for searchingString: String) -> [ContactModel]? {
        let requestContact: NSFetchRequest<Contact> = Contact.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address CONTAINS[c] %@ || name CONTAINS[c] %@",
                                               searchingString,
                                               searchingString)
        do {
            let results = try mainContext.fetch(requestContact)
            return results.map {
                return ContactModel.fromCoreData(crModel: $0)
            }
        } catch {
            return nil
        }
    }

}

enum ContactsDataBaseError: Error {
    case noSuchContactInStorage
    case problemsWithInsertingNewEntity
}
