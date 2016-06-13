//
//  CardCollectionViewController.swift
//  SocialWall
//
//  Created by James Birtwell on 08/06/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import QuartzCore

class CardCollectionViewController: DeviceViewController {
    
    var inSaveMode = false


    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.collectionView.allowsSelection = false
        self.collectionView.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func collectionDoubleTap(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended)
        {
            let point = sender.locationInView(collectionView)
            let indexPath = collectionView.indexPathForItemAtPoint(point)

            //Do what?
        }
    }
    
    @IBAction func connectToTwitter(sender: AnyObject) {
        
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Hashtag",
                                            message: "Enter hashtag search:",
                                            preferredStyle: .Alert)
        
        alertController!.addTextFieldWithConfigurationHandler(
            {(textField: UITextField!) in
                textField.placeholder = "hashtag"
        })
        
        let action = UIAlertAction(title: "Search",
                                   style: UIAlertActionStyle.Default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        if let enteredText = theTextFields[0].text {
                                            GlobalAppWall.activeSocialWall.currentHashtag = enteredText
                                            self!.getActiveSocialWall()
                                        }
                                    }
            })
        
        alertController?.addAction(action)
        self.presentViewController(alertController!,
                                   animated: true,
                                   completion: nil)
        
    }
    
    @IBAction func facebookToggle(sender: AnyObject) {
    }
    @IBAction func twitterToggle(sender: AnyObject) {
    }
    @IBAction func instagramToggle(sender: AnyObject) {
    }

    @IBAction func save(sender: AnyObject) {
        self.collectionView.allowsSelection = !self.collectionView.allowsSelection
        if self.collectionView.allowsSelection == true {
            for post in GlobalAppWall.activeSocialWall.savedPosts {
                if let index = GlobalAppWall.activeSocialWall.displayContent.indexOf({ (socialContent) -> Bool in
                    var myReturn = false
                    if let displayedPost = socialContent as? FacebookPost {
                        myReturn = post.id == displayedPost.id
                    }
                    return myReturn
                }) {
                    let indexPath = NSIndexPath(forItem: index, inSection: 0)
                    self.collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
                }
            }
        } else {
            //deselect all
        }
    }
    
    @IBAction func refresh(sender: AnyObject) {
    }
    
}

extension CardCollectionViewController: DeviceController {
    
    func performSingleScreenOperations() {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.alpha = 1
            self.collectionView.reloadData()
            self.socialWallLogo.alpha = 0
        })
        print("singleScreen")
    }
    
    func performDualScreenOperations() {
        secondaryController.socialArray = GlobalAppWall.activeSocialWall.displayContent
        print("dualScreen")
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
            
        })

        secondaryController.updateCollectionView()
    }

}

extension CardCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, MosaicSocialWall {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = GlobalAppWall.activeSocialWall.displayContent[indexPath.row]
        if let post = selectedItem as? FacebookPost {
            post.save()
            GlobalAppWall.activeSocialWall.savedPosts.append(post)
            GlobalAppWall.activeSocialWall.saveSocialContent()
        }
        
        if let tweet = selectedItem as? Tweet {
            print("tweet")
        }
    }
    //MARK: Standard
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let picDimension = self.view.frame.size.width / 4.0
//        
//        return CGSizeMake(picDimension, picDimension)
//    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if GlobalAppWall.activeSocialWall == nil {
            return 0
        } else {
            return GlobalAppWall.activeSocialWall.displayContent.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! TwitterCollectionViewCell
        
        let socialContent = GlobalAppWall.activeSocialWall.displayContent[indexPath.row]
        
        return makeUpCell(cell, content: socialContent)
    }
 
}

