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
    static var container: NSPersistentContainer = NSPersistentContainer(name: "CoreDataModel")
    static var mainContext: NSManagedObjectContext?
    
    init() {
        ContainerCD.mainContext = ContainerCD.container.viewContext
        ContainerCD.container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }
}
