//
//  FacebookPage.swift
//  SocialWall
//
//  Created by James Birtwell on 21/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import CoreData

struct FacebookPage {
    
    var pageName = "_name_"
    var pageID: String = "_page id_"
    var pageLink = NSURL()
    var pageFans = 0
    var active = true
    
    
    init(object: NSManagedObject) {
        if let name = object.valueForKey(PageKeys.kName) as? String {
            self.pageName = name
        }
        if let id = object.valueForKey(PageKeys.kId)  as? String {
            self.pageID = id
        }
        
        if let fans = object.valueForKey(PageKeys.kFans) as? String {
            if let fanNumber = Int(fans) {
                self.pageFans = fanNumber
            } else {
                self.pageFans = 0
            }
        }
        if let link = object.valueForKey(PageKeys.kLink) as? String {
            if let _link = NSURL(string: link) {
                self.pageLink = _link
            }
        }
        if let active = object.valueForKey(PageKeys.kActive) as? Bool {
            self.active = active
        }
    }
    
    init(page: NSDictionary) {
        
        if let name = page.valueForKey(PageKeys.kName) as? String {
            self.pageName = name
        }
        if let id = page.valueForKey(PageKeys.kId)  as? String {
            self.pageID = id
        }
        
        if let fans = page.valueForKey(PageKeys.kFans) as? String {
            if let fanNumber = Int(fans) {
                self.pageFans = fanNumber
            } else {
                self.pageFans = 0
            }
        }
        if let link = page.valueForKey(PageKeys.kLink) as? String {
            if let _link = NSURL(string: link) {
                self.pageLink = _link
            }
        }
    }
    
    func delete(){
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

        if let pages = CoreDataHelpers.fetchObjects(PageKeys.kEntityName, predicate: self.pageID) {
            managedContext.deleteObject(pages[0])
        }
    }
    
    
    func editSave() {
        if let editPage = CoreDataHelpers.fetchObjects(PageKeys.kEntityName, predicate: self.pageID) {
            print("fetchedForund: \(editPage.count)")
            saveCoreData(editPage[0])
        } else {
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let entity =  NSEntityDescription.entityForName(PageKeys.kEntityName, inManagedObjectContext:managedContext)
            saveCoreData(NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext))
        }
    }
    
    private func saveCoreData(page: NSManagedObject)  {
        
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        page.setValue(self.pageName, forKey: PageKeys.kName)
        page.setValue(self.pageID, forKey: PageKeys.kId)
        page.setValue(self.pageFans, forKey: PageKeys.kFans)
        page.setValue(String(self.pageLink), forKey: PageKeys.kLink)
        page.setValue(self.active, forKey: PageKeys.kActive)
        print("objectTosave: \(page)")

        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    struct PageKeys {
        static let kEntityName = "FacebookPage"
        static let searchGraph = ""
        static let kId = "id"
        static let kName = "name"
        static let kFans = "fan_count"
        static let kLink = "link"
        static let kActive = "active"
    }
    

}