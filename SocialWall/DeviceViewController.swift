//
//  ViewController.swift
//  SocialWall
//
//  Created by James Birtwell on 10/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import Accounts
import Social

class DeviceViewController: UIViewController {

    var secondaryController = SecondaryViewController()
    var itemNo = 1
    
    static let kLoadComplete = "LoadComplete"
    
    @IBOutlet weak var socialWallLogo: UIImageView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if GlobalAppWall.activeSocialWall == nil {
            //Show socialWall setup
            GlobalAppWall.activeSocialWall = SocialWall(withId: "main")
            
        } else {
            if GlobalAppWall.wallNeedsLoading == true {
                self.getActiveSocialWall()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    //Subscribing to a UIScreenDidConnect/DisconnectNotification to react to changes in the status of connected screens.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(self.screenConnectionStatusChanged) , name:UIScreenDidConnectNotification, object:nil)
        notificationCenter.addObserver(self, selector: #selector(self.screenConnectionStatusChanged), name:UIScreenDidDisconnectNotification, object:nil)
        notificationCenter.addObserver(self, selector: #selector(self.loadComplete), name: DeviceViewController.kLoadComplete, object: nil)
//=         let applicationStatusChangedNotification = NSNotificationCenter.defaultCenter()
//        applicationStatusChangedNotification.addObserver(self, selector:("applicationWillResignActive:"), name:UIApplicationWillResignActiveNotification, object:nil)
//        applicationStatusChangedNotification.addObserver(self, selector: ("applicationDidBecomeActive:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
//        
        screenConnectionStatusChanged()
    }
    
    func getActiveSocialWall() {
        
        GlobalAppWall.wallNeedsLoading = false
        if GlobalAppWall.activeSocialWall.currentHashtag != "" {
            self.twitterRequest()
        }
        if GlobalAppWall.activeSocialWall.pages.count != 0 {
        self.facebookRequest(GlobalAppWall.activeSocialWall.pages[0])
//            for page in socialWall.pages {
//                self.facebookRequest(page.pageLink)
//            }
        }
        
    }
    
    func loadComplete () {
        print(GlobalAppWall.fetchingData)
        GlobalAppWall.fetchingData -= 1
        if GlobalAppWall.fetchingData == 0 {
            GlobalAppWall.activeSocialWall.setDisplayContent(self)
        }
    }
    
    @IBAction func expandOnPress(sender: AnyObject) {
        secondaryController.expandImage(NSIndexPath(forItem: itemNo, inSection: 0))
        itemNo += 1
    }
    
    func screenConnectionStatusChanged () {
        if (UIScreen.screens().count == 1) {
// single screen code
        }   else {
// dual screen code
            if  let myDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                if myDelegate.secondaryWindow != nil {
                    if myDelegate.secondaryWindow?.rootViewController is SecondaryViewController {
                        secondaryController = myDelegate.secondaryWindow?.rootViewController as!SecondaryViewController
                        updateCollectionsWithData()
                    }
                }
            }
        }
    }
    
    func updateCollectionsWithData () {
        //RecordCountOfSocialArray
        //GetNewSocialArry
        //OrUpdate Individual elements
        
        if  GlobalAppWall.activeSocialWall.tweets.count > 0 {
//            print("tweets \(GlobalAppWall.activeSocialWall.tweets[0].count)")
            if GlobalAppWall.activeSocialWall.posts.count > 0 {
//                print("posts \(GlobalAppWall.activeSocialWall.posts[0].count)")
                GlobalAppWall.activeSocialWall.setDisplayContent(self)
                if UIScreen.screens().count == 1 {
                    if let vc = self as? DeviceController {
                        vc.performSingleScreenOperations()
                    }
                } else {
                    if let vc = self as? DeviceController {
                        vc.performDualScreenOperations()
                    }
                }
            }
        }
    }
    
    
    
    func facebookRequest(page: FacebookPage) {
        GlobalAppWall.fetchingData += 1
        let fieldArray = [FacebookPost.FacebookKey.kFrom, FacebookPost.FacebookKey.kId, FacebookPost.FacebookKey.kMessage, FacebookPost.FacebookKey.kAttachments, FacebookPost.FacebookKey.kShare, FacebookRequest.kLikeSummary, FacebookRequest.kCommentSummary]
        let request = FacebookRequest()
        let paramenters = ["fields" : fieldArray.joinWithSeparator(","), "limit" : "100"]
        
        request.fetchFbPostsFrom(page, parameters: paramenters, handler: handleFBPosts)
        
    }

    
    func handleFBPosts(posts: [FacebookPost]) {
        print(posts.count)
        GlobalAppWall.activeSocialWall.posts = posts
        self.updateCollectionsWithData()
    }
    
    
    func twitterRequest() {
        GlobalAppWall.fetchingData += 1
        let request = TwitterRequest(search: "London", count: 100)
        request.fetchTweets {( newTweets ) -> Void in
            if newTweets.count > 0 {
                print(newTweets.count)
                GlobalAppWall.activeSocialWall.tweets.append(newTweets)
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.postNotificationName(DeviceViewController.kLoadComplete, object: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    let reuseID = "myCell"

}

extension  DeviceViewController : SocialWallDisplayDelegate {
    
    func displayAciveSocialWall() {
        if UIScreen.screens().count == 1 {
            if let vc = self as? DeviceController {
                vc.performSingleScreenOperations()
            }
        } else {
            if let vc = self as? DeviceController {
                vc.performDualScreenOperations()
            }
        }

    }
}
