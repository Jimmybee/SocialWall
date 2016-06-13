//
//  SecondaryViewController.swift
//  SecondScreen
//
//  Created by Julian Abentheuer on 10.11.14.
//  Copyright (c) 2014 Aaron Abentheuer. All rights reserved.
//

import UIKit

class SecondaryViewController: UIViewController, MosaicSocialWall {
    
    private var mirroredScreenResolution : CGRect?
    var timerLayout: NSTimer?
    var timerPopout: NSTimer?
    
    var socialArray = [SocialContent]()
    var expanded = false
    
    var expandedImage = UIImageView()
    var popupView = PopupView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var popupLabel: UILabel!
    
    @IBOutlet weak var hiddenPopupView: UIView!
    @IBOutlet weak var popupY: NSLayoutConstraint!
    @IBOutlet weak var popupX: NSLayoutConstraint!

    @IBOutlet weak var popupImage: UIImageView!
    @IBOutlet weak var imgBottom: NSLayoutConstraint!
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var viewBorderHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBorderWidth: NSLayoutConstraint!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var detailTopImgGap: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.popupView.alpha = 0
        self.viewBorder.layer.borderColor = UIColor.blackColor().CGColor
        self.viewBorder.layer.borderWidth = 1
        
    }
    
//    @IBOutlet weak var popupImage: UIImageView!
//    @IBOutlet weak var popupLabel: UILabel!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func updateCollectionView () {
        timerPopout?.invalidate()
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
            self.startPopoutTimer()

        })
    }
    
    func getAttributes () {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        collectionView.layoutAttributesForItemAtIndexPath(indexPath)?.frame
        
    }
    
    func timerShowPopup() {
        let random = arc4random_uniform(UInt32(self.collectionView.visibleCells().count))
        let randomIndex = Int(random) + 1
        let nsIndexPath = NSIndexPath(forItem: randomIndex, inSection: 0)
        showHiddenPopup(nsIndexPath)
    }
    
    func showHiddenPopup(indexPath: NSIndexPath ) {
        let frame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame
        
        popupImage.image = socialArray[indexPath.row].getImage()
        if let post = socialArray[indexPath.row] as? FacebookPost {

            popupLabel.text = post.message
        }
        
        if let tweet = socialArray[indexPath.row] as? Tweet {
            popupLabel.text = tweet.text
        }

        
        self.popupX.constant = frame.origin.x - 10
        self.popupY.constant = frame.origin.y - 10
        self.imgHeight.constant = frame.height
        self.imgWidth.constant = frame.width

        self.popupView.alpha = 1
        self.popupImage.contentMode = .ScaleAspectFill
    
        self.viewBorderHeight.constant = 10
        self.viewBorderWidth.constant = 10
        
        self.detailView.alpha = 0
        self.detailViewBottom.active = false
        self.imgBottom.active = true
        
        self.startLayoutTimer()
       
    }
    
    func startLayoutTimer() {
        self.timerLayout = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(SecondaryViewController.pauseLayout), userInfo: nil, repeats: false)
    }
    
    func startPopoutTimer() {
        self.timerPopout = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(SecondaryViewController.timerShowPopup), userInfo: nil, repeats: true)
    }
    
    func pauseLayout() {
        
//        let imageSize = popupImage.image.
        
        UIView.animateWithDuration(1, delay: 0, options: .CurveEaseOut, animations: {
            let aspectRatio = self.popupImage.image!.size.width / self.popupImage.image!.size.height
            if aspectRatio > 1 {
                self.imgWidth.constant = self.view.bounds.width / 2
                self.imgHeight.constant = self.imgWidth.constant / aspectRatio
            } else {
                self.imgHeight.constant =  self.view.bounds.height / 2
                self.imgWidth.constant = self.imgHeight.constant * aspectRatio
            }
            
            self.popupX.constant = self.view.bounds.midX - (self.imgWidth.constant)
            self.popupY.constant = self.view.bounds.midY - (self.imgHeight.constant)
            
            self.view.layoutIfNeeded()
            
            self.popupView.alpha = 1

            }) { (true) in
                UIView.animateWithDuration(1, animations: {
                }) { (true) in
                    UIView.animateWithDuration(1, animations: {
                        self.popupImage.contentMode = .ScaleAspectFit
                        
                        self.imgBottom.active = false
                        self.detailViewBottom.active = true
                        self.detailView.alpha = 1
                        self.view.layoutIfNeeded()
                        }, completion: { (true) in
                            UIView.animateWithDuration(1, animations: {
//                                self.popupLabelBottom.active = false
//                                self.popupHeight.active = true
                            })
                    })
                    
                }
        }
    
     
        
    }
    
    func expandImage(indexPath: NSIndexPath) {
        
        func getFBImage(postUrl: NSURL) -> UIImage? {
            if let data = NSData(contentsOfURL: postUrl){
                return UIImage(data: data)
            }
            return nil
        }
        
        if expandedImage.superview  === self.view {
            self.expandedImage.removeFromSuperview()
        }
        
//        let cell = collectionView(self.collectionView, cellForItemAtIndexPath: indexPath) as! TwitterCollectionViewCell
//        
//        let url = cell.url
//        let image = cell.cellImage.image
//        expandedImage = UIImageView(image: image)

        if let post = socialArray[indexPath.row] as? FacebookPost {
            if let data = NSData(contentsOfURL: post.mediaItem.url!){
                let myImage =  UIImage(data: data)
                expandedImage = UIImageView(image: myImage)
                
            }
        }
        
        if let tweet = socialArray[indexPath.row] as? Tweet {
            if tweet.media.count > 0 {
                if let data = NSData(contentsOfURL: tweet.media[0].url!){
                    let myImage =  UIImage(data: data)
                    expandedImage = UIImageView(image: myImage)
                }
            } else {
                let myImage = UIImage(named: "squareTweet")
                expandedImage = UIImageView(image: myImage)

            }
        }
        
        self.expandedImage.frame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame
        self.view.addSubview(expandedImage)
        
        UIView.animateWithDuration(0.3) {
            self.expandedImage.frame = CGRectMake(240, 120, 240, 240)
            self.expandedImage.contentMode = UIViewContentMode.ScaleAspectFit
            self.expandedImage.alpha = 1
            self.expanded = !self.expanded
        }
        
    }

    
    //MARK: Timer
    
    var item = 0
 
 

    
    //MARK: EXEMPLATORY VIEW GENERATION
    //This is just the exemplatory view to demonstrate some basic things on the secondary screen and help you with testing your Apple-TV settings. Feel free to delete all of this whole method, as it just returns a UIView, which is instantiated in the viewDidLoad() method.
   
    let reuseID = "myCell"
}
    


extension SecondaryViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
        
        
        
        func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
            return 1
        }
        
        func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let picDimension = self.view.frame.size.width / 4.0
            return CGSizeMake(picDimension, picDimension)
        }

        
        func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.socialArray.count
        }
        
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! TwitterCollectionViewCell
            
            let socialContent = socialArray[indexPath.row]
//            print(indexPath)
            return makeUpCell(cell, content: socialContent)
            
        }
        
    }


