//
//  ContactModel.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import CoreData

protocol IContactStorage {
    func saveContact() throws
    func deleteContact() throws
}

public class Contact {
    let address: String
    let name: String
    
    public init(crModel: ContactModel) throws {
        guard let address = crModel.address,
            let name = crModel.name else {
                throw Errors.StorageErrors.cantCreateContact
        }
        self.address = address
        self.name = name
    }

    public init(contact: Contact) {
        self.address = contact.address
        self.name = contact.name
    }
    
    public init(address: String,
         name: String) {
        self.address = address
        self.name = name
    }
}

extension Contact: IContactStorage {
    public func saveContact() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "ContactModel", into: context) as? ContactModel else {
                error = Errors.StorageErrors.cantCreateContact
                group.leave()
                return
            }
            entity.address = self.address
            entity.name = self.name
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
    
    public func deleteContact() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        let requestContact: NSFetchRequest<ContactModel> = ContactModel.fetchRequest()
        requestContact.predicate = NSPredicate(format: "address CONTAINS[c] %@ || name CONTAINS[c] %@",
                                               self.address,
                                               self.name)
        do {
            let results = try ContainerCD.context.fetch(requestContact)
            guard let wallet = results.first else {
                error = Errors.StorageErrors.wrongContact
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
}

extension Contact: Equatable {
    public static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.address == rhs.address
    }
}
