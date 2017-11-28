//
//  SharedDataStore.swift
//  eduid-iOS
//
//  Created by Blended Learning Center on 28.11.17.
//  Copyright © 2017 Blended Learning Center. All rights reserved.
//

import Foundation
import CoreData

class SharedDataStore : NSObject {
    
    var managedObjectContext : NSManagedObjectContext?
    var managedObjectModel : NSManagedObjectModel?
    var persistentStoreCoordinator : NSPersistentStoreCoordinator?
    var persistentStore : NSPersistentStore?
    
    let Shared_Group_Context = "group.mobinaut.test"
    
    override init() {
        super.init()
        setupCoreData()
    }
    
    func setupCoreData() {
        self.managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)!
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel!)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        
    }
    
}

