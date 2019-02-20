//
//  ContactStorage.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import CoreData

protocol IContactStorage {
    func saveContact() throws
    func deleteContact() throws
}

extension Contact: IContactStorage {
    public func saveContact() throws {
        let group = DispatchGroup()
        group.enter()
        var error: Error?
        ContainerCD.persistentContainer.performBackgroundTask { (context) in
            guard let entity = NSEntityDescription.insertNewObject(forEntityName: "ContactModel", into: context) as? ContactModel else {
                error = Errors.ContactErrors.cantCreateContact
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
                error = Errors.ContactErrors.wrongContact
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
