//
//  CuratedWallsTableViewController.swift
//  SocialWall
//
//  Created by James Birtwell on 22/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import CoreData

class CuratedWallsTableViewController: UITableViewController {
    
    var socialWalls = [SocialWall]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let objects = CoreDataHelpers.fetchObjects(SocialWall.Keys.kEntityName) {
            for object in objects {
                let newSocialWall = SocialWall(object: object)
                socialWalls.append(newSocialWall)
            }
        }
        
        
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CuratedWallsTableViewController {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.socialWalls.count > 0 {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.tableView.backgroundView = UIView()
            return 1
        } else {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height ))
            messageLabel.text = "No social walls saved"
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "Palatino", size: 20)
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialWalls.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
 
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
        cell.textLabel?.text = socialWalls[indexPath.row].id
        cell.detailTextLabel?.text = "Page count: \(socialWalls[indexPath.row].pages.count)"
        
        // set cell
        return cell
    }
}


