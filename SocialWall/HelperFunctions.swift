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
    
        
    
    static func getImage(imageView: UIImageView, postUrl: NSURL)  {
        if let data = NSData(contentsOfURL: postUrl){
            dispatch_async(dispatch_get_main_queue(), {
                imageView.image = UIImage(data: data)
            })
        }
    }

}