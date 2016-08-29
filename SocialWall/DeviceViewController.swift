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
        
        screenConnectionStatusChanged()

    }

    
    func expandWall() {
        GlobalAppWall.wallNeedsLoading = false
        if GlobalAppWall.activeSocialWall.currentHashtag != "" {
            GlobalAppWall.activeSocialWall.olderTwitterRequest()
        }
        
        if GlobalAppWall.activeSocialWall.pages.count != 0 {
            GlobalAppWall.activeSocialWall.facebookRequest()
        }
    }
    
    func getActiveSocialWall() {
        
        GlobalAppWall.wallNeedsLoading = false
        if GlobalAppWall.activeSocialWall.currentHashtag != "" {
            GlobalAppWall.activeSocialWall.twitterRequest()
        }
        
        if GlobalAppWall.activeSocialWall.pages.count != 0 {
            GlobalAppWall.activeSocialWall.facebookRequest()
        }
        
    }
    
    func loadComplete () {
        print("fetchData: \(GlobalAppWall.fetchingData)")
        GlobalAppWall.fetchingData -= 1
        if GlobalAppWall.fetchingData == 0 {
            GlobalAppWall.activeSocialWall.setDisplayContent(self)
        }
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
                            secondaryController.updateCollectionView()
                        secondaryController.delegate = self

                    }
                }
            }
        }
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
