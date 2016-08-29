//
//  PresenterViewController.swift
//  SocialWall
//
//  Created by James Birtwell on 18/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit

class PresenterViewController: DeviceViewController, MosaicSocialWall {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var socialArray = [SocialContent]()
    var highlightView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCollectionView () {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
            
        })
    }
    
    @IBAction func doubleTap(sender: UITapGestureRecognizer) {
        print("doubtleTap")
    }
    //MARK SecondScreen Methods
    
    
}


extension  PresenterViewController: DeviceController {
    
    func performSingleScreenOperations() {
        self.socialArray = GlobalAppWall.activeSocialWall.displayContent
        self.updateCollectionView()
        print("singleScreen")
    }
    
    func performDualScreenOperations() {
        secondaryController.socialArray = GlobalAppWall.activeSocialWall.displayContent
        self.socialArray = GlobalAppWall.activeSocialWall.displayContent
        print("dualScreen")
        print(socialArray.count)
        self.updateCollectionView()
        secondaryController.updateCollectionView()
    }
    
    func removeDisplaysWhileLoading(){
        GlobalAppWall.activeSocialWall.displayContent.removeAll()
        self.collectionView.reloadData()
    }
}


extension PresenterViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        self.highlightCellWith(indexPath)
        if UIScreen.screens().count == 2 {
//        secondaryController.expandImage(indexPath)
            secondaryController.showHiddenPopup(indexPath)
        }
        
    }
    
    func highlightCellWith(indexPath: NSIndexPath) {
        if highlightView.superview === self.collectionView {
            highlightView.removeFromSuperview()
        }
        
        highlightView.frame = collectionView.layoutAttributesForItemAtIndexPath(indexPath)!.frame
        highlightView.layer.borderWidth = 2
        highlightView.layer.borderColor = UIColor.yellowColor().CGColor
        self.collectionView.addSubview(highlightView)
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        removeDisplaysWhileLoading()
        return true
    }
    
   
    
    //MARK: Standard
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 4.0
        return CGSizeMake(picDimension, picDimension)
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return GlobalAppWall.activeSocialWall.displayContent.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseID, forIndexPath: indexPath) as! TwitterCollectionViewCell
        
        let socialContent = GlobalAppWall.activeSocialWall.displayContent[indexPath.row]
        
        return makeUpCell(cell, content: socialContent)
    }
    
}
