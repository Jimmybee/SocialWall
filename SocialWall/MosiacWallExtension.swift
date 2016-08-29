//
//  File.swift
//  SocialWall
//
//  Created by James Birtwell on 23/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit

protocol MosaicSocialWall {
    
//    var socialArray: [SocialContent] { get set }
    
    func makeUpCell(cell: TwitterCollectionViewCell, content: SocialContent) -> TwitterCollectionViewCell
    

}



extension MosaicSocialWall {
    
    
    func makeUpCell (cell: TwitterCollectionViewCell, content: SocialContent) -> TwitterCollectionViewCell {
        
        if let post = content as? FacebookPost {
//            cell.url = post.mediaItem.url
            cell.post = post
            cell.tweetLabel.alpha = 0
        }
        
        if let tweet = content as? Tweet {
            if tweet.media.count > 0 {
                if let url = tweet.media[0].url {
                    //                    print(url)
                    cell.tweet = tweet
                    //                    HelperFunctions.getImage(cell.cellImage, postUrl: url)
                }
                cell.tweetLabel.alpha = 0
            } else {
                cell.cellImage.image = UIImage(named: "squareTweet")
                cell.tweetLabel.text = tweet.text
                cell.tweetLabel.alpha = 1
            }
        }
        
        return cell
    }

    
}
