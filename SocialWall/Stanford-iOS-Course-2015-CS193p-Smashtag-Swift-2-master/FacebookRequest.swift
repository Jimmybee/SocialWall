//
//  FacebookRequest.swift
//  SocialWall
//
//  Created by James Birtwell on 14/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import Foundation
import Accounts
import Social

var facebookAccount: ACAccount?

class FacebookRequest {
    
    let forceNewPermissions = true
    
    func fetchFbPostsFrom(page: FacebookPage, parameters: [NSObject: AnyObject]?, handler: ([FacebookPost]) -> Void)  {
        
        let pageGraphUrl = String(page.pageLink).stringByReplacingOccurrencesOfString(FacebookRequest.kNormalURL, withString: FacebookRequest.kGraphURL)
        let feedURL = NSURL(string:  pageGraphUrl + FacebookRequest.kGraphFeed)
        let slRequest = SLRequest(forServiceType: SLServiceTypeFacebook, requestMethod: SLRequestMethod.GET, URL: feedURL, parameters: parameters)

        fetchWithFunction(slRequest) { results in
            do {
                var posts = [FacebookPost]()

                
                let feed = try NSJSONSerialization.JSONObjectWithData(results as! NSData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                if let feedData = feed.valueForKey(FacebookPost.FacebookKey.kData) as? [NSDictionary] {
                    for post in feedData {
                        if let postFromName = post.valueForKeyPath("from.name") as? String {
                            if postFromName == page.pageName {
                                let newPost = FacebookPost(postDictionary: post)
                                posts.append(newPost)
                            }
                        }
                    }
                }
                handler(posts)
                
            } catch {
                return
            }

        }
    }
    
    func fetchWithFunction (request: SLRequest, handler: (AnyObject?) -> Void) {
        if forceNewPermissions == false {facebookAccount = nil}
        makeRequest(request, handler: handler)
    }
    
    
    func makeRequest(request: SLRequest ,handler: (AnyObject?) -> Void) {
    
        
        
        if let account = facebookAccount {
            request.account = account
            
         

            request.performRequestWithHandler({ (meData, putResponse, error) in
                if error != nil {
                    print("error: \(error)")
                    return
                }
                
                handler(meData)
              
            })
            
        } else {
            
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
            let postingOptions = [ACFacebookAppIdKey: AppDelegate.kFacebookAppID, ACFacebookPermissionsKey: [], ACFacebookAudienceKey: ACFacebookAudienceFriends]
            
            
            accountStore.requestAccessToAccountsWithType(accountType, options: postingOptions as [NSObject : AnyObject], completion: { (success, error) in
                let accountsArray =
                    accountStore.accountsWithAccountType(accountType)
                if accountsArray == nil {
                    print("no accounts")
                } else {
                    if accountsArray.count > 0 {
                        facebookAccount = accountsArray[0] as? ACAccount
                        self.makeRequest(request, handler: handler)
                        
                    }
                }
            })
            
        }
        
    }
    
    static let kNormalURL = "https://www.facebook.com/"
    static let kGraphURL = "https://graph.facebook.com/"
    static let kGraphFeed = "feed"
    static let kCommentSummary = "comments.limit(0).summary(true)"
    static let kLikeSummary = "likes.limit(0).summary(true)"
    
    
}