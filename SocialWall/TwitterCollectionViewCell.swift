//
//  TwitterCollectionViewCell.swift
//  SocialWall
//
//  Created by James Birtwell on 10/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit

class TwitterCollectionViewCell: UICollectionViewCell {
    
    var url:NSURL? {
        didSet {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { () -> Void in
                if let imageURL = self.url {
                    HelperFunctions.getImage(self.cellImage, postUrl: imageURL)
                }
            }
        }
    }
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var tweetLabel: UILabel!
    
    
    override var highlighted: Bool {
        didSet {
            if highlighted == true {
                self.layer.opacity = 0.6
            }
            if highlighted == false {
                self.layer.opacity = 1
            }
        }
    }
    
    override var selected : Bool {
        didSet {
            if selected == true {
                self.backgroundColor = UIColor.orangeColor()
            } else {
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    

}
