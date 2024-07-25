//
//  PersistenceManager.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 23/07/24.
//

import Foundation
import CoreData
// To avoid warnings when saving to CoreData: These warnings occur because multiple managed object models are the same managed object subclass
class PersistenceManager {
    let storeName: String! = nil

   //In NSPersistentContainer only one NSManagedObjectModel to avoid warnings
    static var managedObjectModel: NSManagedObjectModel = {
            let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: PersistenceManager.self)])!
            return managedObjectModel
        }()

    
}
