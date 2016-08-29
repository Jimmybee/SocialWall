//
//  HelperFunctions.swift
//  SocialWall
//
//  Created by James Birtwell on 18/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit

class HelperFunctions {
    
    static func gcd(a: CGFloat, _ b: CGFloat) -> CGFloat {
        let r = a % b
        if r != 0 {
            return gcd(b, r)
        } else {
            return b
        }
    }
    
        
    
    static func getImage(imageView: UIImageView, postUrl: NSURL, post: FacebookPost? = nil, tweet: Tweet? = nil)  {
        if let data = NSData(contentsOfURL: postUrl){
            dispatch_async(dispatch_get_main_queue(), {
                imageView.image = UIImage(data: data)
                if let socialItem = post {socialItem.mediaItem.image = UIImage(data: data)}
                if let socialItem = tweet {socialItem.media[0].image = UIImage(data: data)}
            })
        }
    }

}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}