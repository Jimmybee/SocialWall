//
//  FacebookSearch.swift
//  SocialWall
//
//  Created by James Birtwell on 20/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import Foundation
import Accounts
import Social


//search?q=ford&type=page

class FacebookSearch {
    
    func httpSearch (searchString: String, accessToken: String, handler: ([FacebookPage]) -> ()) {

        var pagesFound = [FacebookPage]()

        pagesFound.removeAll()

//        var fields = [String]()
        let escapedSearchString:String! = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        if escapedSearchString == nil {
            return
        }
        
        let fbGraphURL = NSURL(string: "https://graph.facebook.com/search?access_token=\(accessToken)&q=\(escapedSearchString)&fields=id,name,fan_count,link&type=page")
        
        let urlSession = NSURLSession.sharedSession().dataTaskWithURL(fbGraphURL!) { (data, response, error) in
            if data != nil {
                do {
                    if let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        if let dictDataArray = dict.valueForKey("data") as? [NSDictionary] {
                            for page in dictDataArray {
                                let newPage = FacebookPage(page: page)
                                pagesFound.append(newPage)
                            }
                        }
                        
                        
                        handler(pagesFound)
                    }
                    
                } catch {
                    print("caught")
                }
            }
            if error != nil {
                //                 print("error: \(error)")
            }
            if response != nil {
                //                print(response)
            }
        }
        
        urlSession.resume()
    }
    
    
}