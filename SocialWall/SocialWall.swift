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
    var pages = [FacebookPage]() {didSet {
            self.nextFeedEdge = nil
            self.posts.removeAll()
            self.displayContent.removeAll()
        }
    }
    var currentHashtag = "" {didSet {
            hashtagHistory.append(oldValue)
            self.lastSuccessfulTwitterRequest = nil
            self.saveHashtag()
            self.tweets.removeAll()
            self.displayContent.removeAll()
        }
    }
    var hashtagHistory = [String]() //TODO: Save 
    var posts = [FacebookPost]()
    var tweets = [[Tweet]]()
    var savedPosts = [FacebookPost]()
    var savedTweets = [Tweet]()
    var displayItems = 200
    var liveData = true
    var onlyWithMedia = true
    var showPosts = true
    var showTweets = true
    var showInstas = true
    var needsLoading = true
    
    
    //MARK: Initilization
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
        
        if let set = object.valueForKey(Keys.kHashtags) as? NSSet {
            for setItem in set {
                if let setObject = setItem as? NSManagedObject {
                    if let hashtag = setObject.valueForKey("hashtag") as? String {
                        self.hashtagHistory.append(hashtag)
                    }
                }
            }
        }
        
        if let currentHashtag = object.valueForKey(Keys.kCurrentHashtag)  as? String {
            self.currentHashtag = currentHashtag
        }
            
    }
    
    
    //MARK: setting display content

    
    func setDisplayContent(delegate: SocialWallDisplayDelegate, addTo: Bool = false) {
        var tweetSection = 0
        var tweetsAdded = 0
        var postsAdded = 0
        
        if !addTo {
            self.displayContent.removeAll()
            //notify no display content
        }
        
        var latestTweets = [Tweet]()
        
        //TODO: Premium feature
//        self.savedPosts.forEach { (post) in
//            socialContent.append(post)
//        }
//        
//        self.savedTweets.forEach { (tweet) in
//            socialContent.append(tweet)
//        }
        
        if self.tweets.count > 0 {
            latestTweets = self.tweets[0]
            print("tweets display: \(latestTweets.count)")

        }
        
        if self.posts.count > 0 {
            print("posts display: \(posts.count)")

        }
        
        socialLoop: while displayContent.count < self.displayItems {
            
            let socialCount = displayContent.count
            if self.showTweets  {
                if tweetsAdded < latestTweets.count {
                    let tweet = latestTweets[tweetsAdded]
                    displayContent.append(tweet)
                    tweetsAdded += 1
                }
            }
            
            if showPosts {
                if postsAdded < posts.count {
                    let post = posts[postsAdded]
                    displayContent.append(post)
                    postsAdded += 1
                }
            }
            
            if displayContent.count == socialCount {
                break socialLoop
            }
            
        }
        
        print("dislay Content: \(displayContent.count)")
        delegate.displayAciveSocialWall()
    }
    
    func updateTweetsDisplayed() {
        self.displayContent.removeFirst()
        //update a single index, notify wall or refresh for new tweets
        
    }

    //
    
//    MARK:Core Data Saving
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
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func saveHashtag() {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let wallObject = getManagedObject()
        wallObject.setValue(self.currentHashtag, forKey: Keys.kCurrentHashtag)
        
        do {
            try managedContext.save()
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
        static let kHashtags = "hashtagHistory"
        static let kCurrentHashtag = "currentHashtag"
    }
    
    struct notifications {
        static let kNeedMoreData = "needMoreData"
    }
    //MARK: Requests:
    
    var lastSuccessfulTwitterRequest: TwitterRequest?
    var nextTwitterRequest: TwitterRequest? {
        if lastSuccessfulTwitterRequest == nil {
            if self.currentHashtag != "" {
                return TwitterRequest(search: self.currentHashtag, count: 100, withMedia: onlyWithMedia)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulTwitterRequest!.requestForNewer
        }
    }

    func twitterRequest() {
        GlobalAppWall.fetchingData += 1
        if let request = nextTwitterRequest {
            request.fetchTweets({ (newTweets) in
                self.tweets.insert(newTweets, atIndex: 0)
                self.lastSuccessfulTwitterRequest = request
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(DeviceViewController.kLoadComplete, object: nil)

            })
        }
    }
    
    func olderTwitterRequest() {
        GlobalAppWall.fetchingData += 1
        if let request = lastSuccessfulTwitterRequest?.requestForOlder {
            request.fetchTweets({ (newTweets) in
                self.tweets[0].appendContentsOf(newTweets)
                self.lastSuccessfulTwitterRequest = request
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(DeviceViewController.kLoadComplete, object: nil)
            })
        }
    }
    
    func initialTwitterHandler(newTweets: [Tweet]) {
        if newTweets.count > 0 {
                    }
    }
    
    func apppendTwitterHandler(newTweets: [Tweet]) {
        if newTweets.count > 0 {
            self.tweets[0].appendContentsOf(newTweets)
            self.lastSuccessfulTwitterRequest = nextTwitterRequest
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName(DeviceViewController.kLoadComplete, object: nil)
        }
    }
    
    //MARK: Facebook
    var nextFeedEdge: String?

    func facebookRequest() {
        GlobalAppWall.fetchingData += 1
        let fieldArray = [FacebookPost.FacebookKey.kFrom, FacebookPost.FacebookKey.kId, FacebookPost.FacebookKey.kMessage, FacebookPost.FacebookKey.kAttachments, FacebookPost.FacebookKey.kShare, FacebookRequest.kLikeSummary, FacebookRequest.kCommentSummary]
        let request = FacebookRequest()
        let paramenters = ["fields" : fieldArray.joinWithSeparator(","), "limit" : "100"]
        
        request.fetchFbPostsFrom(self.pages[0], nextEdge: self.nextFeedEdge, parameters: paramenters, handler: handleFBPosts)
        
    }
    
    func handleFBPosts(posts: [FacebookPost], nextPage: String) {
        self.posts.appendContentsOf(posts)
        if nextPage.characters.count < 46 {
            self.nextFeedEdge = nil
        } else {
            self.nextFeedEdge = nextPage[32...46]
        }
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName(DeviceViewController.kLoadComplete, object: nil)
    }


}