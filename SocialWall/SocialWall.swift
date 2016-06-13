//
//  SocialWall.swift
//  SocialWall
//
//  Created by James Birtwell on 21/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import CoreData

protocol SocialWallDisplayDelegate {
    func displayAciveSocialWall ()
}

class SocialWall {
    
    var id = "newWall"
    var displayContent = [SocialContent]()
    var pages = [FacebookPage]()
    var currentHashtag = "" 
    var hashtagHistory = [String]()
    var posts = [FacebookPost]()
    var tweets = [[Tweet]]()
    var savedPosts = [FacebookPost]()
    var savedTweets = [Tweet]()
    var displayItems = 100
    var showPosts = true
    var showTweets = true
    var needsLoading = true
    
    init(withId: String) {
        self.id = withId
    }
    
    init(object: NSManagedObject) {
        if let id = object.valueForKey(Keys.kId)  as? String {
            self.id = id
        }
        if let set = object.valueForKey(Keys.kPages) as? NSSet {
            for setItem in set {
               if let setObject = setItem as? NSManagedObject {
                    let page = FacebookPage(object: setObject)
                    pages.append(page)
                }
            }
        }
        
        if let set = object.valueForKey(Keys.kPosts) as? NSSet {
            for setItem in set {
                if let setObject = setItem as? NSManagedObject {
                    let post = FacebookPost(object: setObject)
                    savedPosts.append(post)
                }
            }
        }
        
    }
    
    
    
//    func save () {
//        if let editPage = CoreDataHelpers.fetchSingleEntityByID(PageKeys.kEntityName, predicate: self.pageID) {
//            saveCoreData(editPage)
//        } else {
//            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//            let entity =  NSEntityDescription.entityForName(PageKeys.kEntityName, inManagedObjectContext:managedContext)
//            saveCoreData(NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext))
//        }
//
    //    }
    
    func setDisplayContent(delegate: SocialWallDisplayDelegate) {
        var socialContent = [SocialContent]()
        var tweetsAdded = 0
        var postsAdded = 0
        
        let postContent:[SocialContent] = savedPosts
        let tweetContent:[SocialContent] = savedTweets

        socialContent = postContent + tweetContent
        
        let tweets = self.tweets[0]
        
        socialLoop: while socialContent.count < self.displayItems {
            
            let socialCount = socialContent.count
            
            if tweetsAdded < tweets.count {
                let tweet = tweets[tweetsAdded]
                socialContent.append(tweet)
                tweetsAdded += 1
            }
            
            if postsAdded < posts.count {
                let post = posts[postsAdded]
                socialContent.append(post)
                postsAdded += 1
            }
            
            if socialContent.count == socialCount {
                break socialLoop
            }
            
        }
        
        self.displayContent = socialContent
        delegate.displayAciveSocialWall()
    }

    
    private func getPagesSet() -> NSMutableSet {
        let pageSet = NSMutableSet()
        for page in pages {
            if let objects = CoreDataHelpers.fetchObjects(FacebookPage.PageKeys.kEntityName, predicate: page.pageID) {
                pageSet.addObject(objects[0])
            }
        }
      return pageSet
    }
    
    private func getPostSet() -> NSMutableSet {
        let postSet = NSMutableSet()
        for post in savedPosts {
            if let objects = CoreDataHelpers.fetchObjects(FacebookPost.FacebookKey.kEntityName, predicate: post.id) {
                postSet.addObject(objects[0])
            }
        }
        print("post set to save:\(postSet.count)")
        return postSet
    }
    
    func saveWall()  {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let wallObject = getManagedObject()
        wallObject.setValue(self.id, forKey: Keys.kId)
        wallObject.setValue(getPagesSet(), forKey: Keys.kPages)
        
        do {
            try managedContext.save()
//            self.
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func saveSocialContent() {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let wallObject = getManagedObject()
        wallObject.setValue(getPostSet(), forKey: Keys.kPosts)
        
        do {
            try managedContext.save()
            print("save succeful")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    private func getManagedObject() -> NSManagedObject {
        if let walls = CoreDataHelpers.fetchObjects(Keys.kEntityName, predicate: self.id) {
            return walls[0]
        } else {
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let entity =  NSEntityDescription.entityForName(Keys.kEntityName, inManagedObjectContext:managedContext)
            return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        }
    }
    
    
    struct Keys {
        static let kEntityName = "SocialWall"
        static let kId  = "id"
        static let kPages = "pages"
        static let kPosts = "posts"
    }
}