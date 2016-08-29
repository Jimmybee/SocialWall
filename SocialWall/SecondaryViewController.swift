//
//  SecondaryViewController.swift
//  SecondScreen
//
//  Created by Julian Abentheuer on 10.11.14.
//  Copyright (c) 2014 Aaron Abentheuer. All rights reserved.
//

import UIKit

class SecondaryViewController: UIViewController, MosaicSocialWall {
    
    static let kDataReadyForDisplay = "dataReadyForDisplay"
    
    private var mirroredScreenResolution : CGRect? {
        didSet {
            print("mirroredScreenResolution: \(mirroredScreenResolution)")
        }
    }
    var timerLayout: NSTimer?
    var timerPopout: NSTimer?
    var delegate: DeviceViewController?
    
    var socialArray = [SocialContent]()
    var expanded = false
    
    var expandedImage = UIImageView()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var popupLabel: UILabel!
    
    @IBOutlet weak var hiddenPopupView: UIView!
    @IBOutlet weak var popupY: NSLayoutConstraint!
    @IBOutlet weak var popupX: NSLayoutConstraint!

    @IBOutlet weak var popupImage: UIImageView!
    @IBOutlet weak var imgBottom: NSLayoutConstraint!
    @IBOutlet weak var imgWidth: NSLayoutConstraint!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    @IBOutlet weak var imgSide: NSLayoutConstraint!
    
    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var viewBorderHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBorderWidth: NSLayoutConstraint!
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var detailViewBottom: NSLayoutConstraint! //toSuperview
//    @IBOutlet weak var detailTopImgGap: NSLayoutConstraint!
    
    @IBOutlet weak var sideDetailView: UIView!
    @IBOutlet weak var sideDetailTrailingToSuperivew: NSLayoutConstraint!
    @IBOutlet weak var sideMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.hiddenPopupView.alpha = 0
        self.viewBorder.layer.borderColor = UIColor.blackColor().CGColor
        self.viewBorder.layer.borderWidth = 1
        
        self.setToDummyArray()
    }
    
    func setToDummyArray() {
        self.socialArray.removeAll()
        for _ in 0...120 {
            self.socialArray.append(DummyContent())
        }
    }
    
//    @IBOutlet weak var popupImage: UIImageView!
//    @IBOutlet weak var popupLabel: UILabel!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func attemptDisplay() {
        timerPopout?.invalidate()
        timerPopout = nil
        if self.collectionView.visibleCells().count == 0 {
            displayTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(attemptDisplay), userInfo: nil, repeats: false)
            return
        }
        if GlobalAppWall.activeSocialWall.displayContent.count == 0 {
            displayTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(attemptDisplay), userInfo: nil, repeats: false)
            return
        }
        if GlobalAppWall.activeSocialWall.displayContent.count < self.collectionView.visibleCells().count {
            delegate?.expandWall()
            print("//Geting more data")
            return
        }
        if GlobalAppWall.activeSocialWall.displayContent.count > self.socialArray.count {
            self.socialArray = GlobalAppWall.activeSocialWall.displayContent
        } else {
        self.socialArray.replaceRange(0...GlobalAppWall.activeSocialWall.displayContent.count-1, with: GlobalAppWall.activeSocialWall.displayContent)
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView.reloadData()
                print("start popout")
                self.startPopoutTimer()
            })
        }
     
    }
    
    var displayTimer: NSTimer?
    
    func updateCollectionView () {
        print("startTimer")
        attemptDisplay()
    }
    
    func getAttributes () {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        collectionView.layoutAttributesForItemAtIndexPath(indexPath)?.frame
        
    }
    
    func timerShowPopup() {
        print("show popup")
        timerLayout?.invalidate()
        timerLayout = nil
        if !GlobalAppWall.screenConnected {
            timerPopout?.invalidate()
            timerPopout = nil
            return
        }
        let random = arc4random_uniform(UInt32(self.collectionView.visibleCells().count))
        let randomIndex = Int(random) + 1
        let nsIndexPath = NSIndexPath(forItem: randomIndex, inSection: 0)
        showHiddenPopup(nsIndexPath)
    }
    
    func showHiddenPopup(indexPath: NSIndexPath ) {
        
        
        
        if collectionView.layoutAttributesForItemAtIndexPath(indexPath) == nil {
            return
        }
        
        let frame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame
        
        if GlobalAppWall.activeSocialWall.displayContent.count < indexPath.row {
            return
        }
        
        popupImage.image = GlobalAppWall.activeSocialWall.displayContent[indexPath.row].getImage()
        if let post = GlobalAppWall.activeSocialWall.displayContent[indexPath.row] as? FacebookPost {
            popupLabel.text = post.message
            sideMessage.text = post.message
        }
        
        if let tweet = GlobalAppWall.activeSocialWall.displayContent[indexPath.row] as? Tweet {
            popupLabel.text = tweet.text
            sideMessage.text = tweet.text
        }

        
        self.popupX.constant = frame.origin.x - 10
        self.popupY.constant = frame.origin.y - 10
        self.imgHeight.constant = frame.height
        self.imgWidth.constant = frame.width

        self.hiddenPopupView.alpha = 1
        self.popupImage.contentMode = .ScaleAspectFill
    
        self.viewBorderHeight.constant = 10
        self.viewBorderWidth.constant = 10
        
        self.detailView.alpha = 0
        self.detailViewBottom.active = false
        self.imgBottom.active = true
        
        self.sideDetailView.alpha = 0
        self.imgSide.active = true
        self.sideDetailTrailingToSuperivew.active = false

        
        self.startLayoutTimer()
       
    }
    
    func startLayoutTimer() {
        self.timerLayout = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(SecondaryViewController.pauseLayout), userInfo: nil, repeats: false)
    }
    
    func startPopoutTimer() {
        self.timerPopout = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(SecondaryViewController.timerShowPopup), userInfo: nil, repeats: true)
    }
    
    func pauseLayout() {
        let aspectRatio = self.popupImage.image!.size.width / self.popupImage.image!.size.height

        UIView.animateWithDuration(1, delay: 0, options: .CurveEaseOut, animations: {
            if aspectRatio > 1 {
                self.imgWidth.constant = self.view.bounds.width / 3
                self.imgHeight.constant = self.imgWidth.constant / aspectRatio
            } else {
                self.imgHeight.constant =  self.view.bounds.height / 3
                self.imgWidth.constant = self.imgHeight.constant * aspectRatio
            }
            
            self.popupX.constant = self.view.bounds.midX - (self.imgWidth.constant)
            self.popupY.constant = self.view.bounds.midY - (self.imgHeight.constant)
            
            self.view.layoutIfNeeded()
            
            }) { (true) in
                    UIView.animateWithDuration(1, animations: {
                        self.popupImage.contentMode = .ScaleAspectFit
                        
                        if aspectRatio > 1 {
                            self.imgBottom.active = false
                            self.detailViewBottom.active = true
                            self.detailView.alpha = 1
                        } else {
                            self.sideDetailView.alpha = 1
                            self.imgSide.active = false
                            self.sideDetailTrailingToSuperivew.active = true
                        }
                        self.view.layoutIfNeeded()
                    })
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
            return socialArray.count
        }
        
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! TwitterCollectionViewCell
            
            let socialContent = socialArray[indexPath.row]
            return makeUpCell(cell, content: socialContent)
            
            
        }

        
}


