//
//  CoreDataHelpers.swift
//  SocialWall
//
//  Created by James Birtwell on 21/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelpers {

    
    static func fetchObjects(entityName: String, predicate: String = "") -> [NSManagedObject]? {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if predicate != "" {
            fetchRequest.predicate = NSPredicate(format: "id = %@", predicate)
        }
        
        do {
            if let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count == 0 {
                    return nil
                }
                return fetchResults
            }
        } catch {
            return nil
        }
        return nil
    }
    
}