//
//  DummyContent.swift
//  SocialWall
//
//  Created by James Birtwell on 15/06/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit


class DummyContent : SocialContent {
    
    var image = UIImage(named: "socialWall120 - iPhonex2")
    
    func getImage() -> UIImage? {
        return image
    }
}