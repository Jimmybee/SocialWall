//
//  TwitterCollectionViewCell.swift
//  SocialWall
//
//  Created by James Birtwell on 10/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit

class TwitterCollectionViewCell: UICollectionViewCell {
    
    var post: FacebookPost? {
        didSet {
            cellImage.image = nil
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { () -> Void in
                if let postImage = self.post?.mediaItem.image {
                    self.cellImage.image = postImage
                } else if let imageURL = self.post?.mediaItem.url {
                    HelperFunctions.getImage(self.cellImage, postUrl: imageURL, post: self.post)
                }
            }
        }
    }
    
    var tweet: Tweet? {
        didSet {
            cellImage.image = nil
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { () -> Void in
                if let tweetImage = self.tweet?.media[0].image {
                    self.cellImage.image = tweetImage
                } else if let imageURL = self.tweet?.media[0].url {
                    HelperFunctions.getImage(self.cellImage, postUrl: imageURL, tweet: self.tweet)
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
