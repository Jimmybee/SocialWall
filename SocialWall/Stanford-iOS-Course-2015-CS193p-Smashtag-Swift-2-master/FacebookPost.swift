//
//  FacebookPost.swift
//  SocialWall
//
//  Created by James Birtwell on 14/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import CoreData


class FacebookPost: SocialContent {
    
    var id = ""
    var from = "from"
    var story = "story"
    var message = "message"
    var likeTotal = 0
    var shareTotal = 0
    var commentTotal = 0
    var attachments:NSData? = NSData()
    var mediaItem = MediaItem()
    
    func getImage() -> UIImage? {
        if let data = NSData(contentsOfURL: self.mediaItem.url!){
            return UIImage(data: data)
        }
        return nil
    }
    
    init(object: NSManagedObject) {
        if let id = object.valueForKey(FacebookKey.kId)  as? String {
            self.id = id
        }
        if let from = object.valueForKey(FacebookKey.kFrom)  as? String {
            self.from = from
        }
        if let message = object.valueForKey(FacebookKey.kMessage)  as? String {
            self.message = message
        }
        if let urlString = object.valueForKey(FacebookKey.kFrom)  as? String {
                self.mediaItem = MediaItem(urlString: urlString)
        }
    }
    
    init(postDictionary: NSDictionary) {
        
        if let id = postDictionary.valueForKey(FacebookKey.kId) as? String {
            self.id = id
        }
        
        if let from = postDictionary.valueForKey(FacebookKey.kFrom) as? String {
            self.from = from
        }
        
        if let attachmentDataDictionary = postDictionary.valueForKey(FacebookKey.kAttachments) as? NSDictionary {
            mediaItem = MediaItem(attachments: attachmentDataDictionary)
        }
        
        
        if let shareDict = postDictionary.valueForKey(FacebookKey.kShare) as? NSDictionary {
            if let shareCount = shareDict.valueForKey("count") as? Int {
                self.shareTotal = shareCount
            }
        }
        
        if let likeDict = postDictionary.valueForKey(FacebookKey.kLikes) as? NSDictionary {
            if let likeSummaryDict = likeDict.valueForKey("summary") as? NSDictionary {
                if let likeCount = likeSummaryDict.valueForKey("total_count") as? Int {
                    self.likeTotal = likeCount
                }
            }
        }
        
        if let commentsDict = postDictionary.valueForKey(FacebookKey.kComments) as? NSDictionary {
            if let commentsSummaryDict = commentsDict.valueForKey("summary") as? NSDictionary {
                if let commentCount = commentsSummaryDict.valueForKey("total_count") as? Int {
                    self.commentTotal = commentCount
                }
            }
        }
        
        if let message = postDictionary.valueForKey(FacebookKey.kMessage) as? String {
            self.message = message
        }
        
        
    }
    
    struct FacebookKey {
        static let kEntityName = "Post"
        static let kId = "id"
        static let kFrom = "from"
        static let kMessage = "message"
        static let kStory = "story"
        static let kData = "data"
        static let kAttachments = "attachments"
        static let kShare = "shares"
        static let kLikes = "likes"
        static let kComments = "comments"
        static let kUrl = "src"
        
    }
    
    struct MediaItem {
        var url: NSURL? = nil
        
        init() {
            
        }
        
        init(urlString: String) {
            if let url = NSURL(string: urlString) {
                self.url = url
            }
        }
        
        init(attachments: NSDictionary) {
            if let postAttachments = attachments.valueForKey("data") as? [NSDictionary] {
                if let media = postAttachments[0].valueForKey("media") as? NSDictionary {
                    if let image = media.valueForKey("image") as? NSDictionary {
                        self.url = NSURL(string: image.valueForKey("src") as! String)
                    }
                }
                if let subattachments = postAttachments[0].valueForKey("subattachments") as? NSDictionary {
                    if let subData = subattachments.valueForKey("data") as? [NSDictionary] {
                        if let media = subData[0].valueForKey("media") as? NSDictionary {
                            if let image = media.valueForKey("image") as? NSDictionary {
                                self.url = NSURL(string: image.valueForKey("src") as! String)
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    func saveCoreData(newWall: NSManagedObject)  {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        newWall.setValue(self.id, forKey: FacebookKey.kId)
        newWall.setValue(self.from, forKey: FacebookKey.kFrom)
        newWall.setValue(self.message, forKey: FacebookKey.kMessage)
        newWall.setValue(String(self.mediaItem.url), forKey: FacebookKey.kUrl)

        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func save() {
        if let posts = CoreDataHelpers.fetchObjects(FacebookKey.kEntityName, predicate: self.id) {
            saveCoreData(posts[0])
        } else {
            let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let entity =  NSEntityDescription.entityForName(FacebookKey.kEntityName, inManagedObjectContext:managedContext)
            saveCoreData(NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext))
        }
    }

    
}