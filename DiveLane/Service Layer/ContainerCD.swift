//
//  ContainerCD.swift
//  DiveLane
//
//  Created by Anton Grigorev on 30/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import CoreData

public class ContainerCD {
    private static var _context: NSManagedObjectContext?
    private static var _container: NSPersistentContainer?
    
    class var context: NSManagedObjectContext {
        get {
            if let context = _context, _container != nil {
                return context
            } else {
                let pc = persistentContainer
                _context = pc.viewContext
                return pc.viewContext
            }
        }
        
        set(context) {
            _context = context
        }
    }
    
    public static var persistentContainer: NSPersistentContainer {
        get {
            if let container = _container {
                return container
            } else {
                let pcontainer = NSPersistentContainer(name: "CoreDataModel")
                pcontainer.loadPersistentStores { (_, error) in
                    if let error = error {
                        fatalError("Failed to load store: \(error)")
                    }
                }
                _container = pcontainer
                return pcontainer
            }
        }
        
        set(container) {
            self._container = container
        }
    }
}
