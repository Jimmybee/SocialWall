//
//  FbPagesTableViewController.swift
//  SocialWall
//
//  Created by James Birtwell on 21/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import CoreData

class FbPagesTableViewController: UITableViewController {
    
        
    struct Constants {
        static let kPageDetailSegue = "PageDetailSegue"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Navigation 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.kPageDetailSegue {
            if let fpdvc = segue.destinationViewController as? FbPageDetailTableViewController  {
                if let indexPath = sender as? NSIndexPath {
                    if indexPath.section == 0 {
                        fpdvc.page = GlobalAppWall.activeSocialWall.pages[indexPath.row]
                    } else {
                        fpdvc.page = GlobalAppWall.inactiveFBPages[indexPath.row]
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController()){
//           SocialWall.sharedInstance.pages = activePages
            
        }
    }
    //MARK: Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(Constants.kPageDetailSegue, sender: indexPath)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return GlobalAppWall.activeSocialWall.pages.count
        } else {
            return GlobalAppWall.inactiveFBPages.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Active Pages"
        } else {
            return "Inactive Pages"
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = GlobalAppWall.activeSocialWall.pages[indexPath.row].pageName
            cell.detailTextLabel?.text = String(GlobalAppWall.activeSocialWall.pages[indexPath.row].pageLink)
        } else {
            cell.textLabel?.text = GlobalAppWall.inactiveFBPages[indexPath.row].pageName
            cell.detailTextLabel?.text = String(GlobalAppWall.inactiveFBPages[indexPath.row].pageLink)
        }
        
        return cell
        
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            confirmDeletePopup(indexPath)
        }
    }
    
    func confirmDeletePopup (indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Delete Page?", message: "Associated saved posts will be removed", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Destructive, handler: { action in
            self.deleteCoreObject(indexPath)
            switch indexPath.section {
            case 0:
                GlobalAppWall.activeSocialWall.pages.removeAtIndex(indexPath.row)
            case 1:
                GlobalAppWall.inactiveFBPages.removeAtIndex(indexPath.row)
            default: break
            }
            self.tableView.reloadData()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func deleteCoreObject(indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            if let objToDelete = CoreDataHelpers.fetchObjects(FacebookPage.PageKeys.kEntityName, predicate: GlobalAppWall.activeSocialWall.pages[indexPath.row].pageID) {
                if objToDelete.count == 1 {
                    GlobalAppWall.managedContext.deleteObject(objToDelete[0])
                }
            } 
        case 1:
            if let objToDelete = CoreDataHelpers.fetchObjects(FacebookPage.PageKeys.kEntityName, predicate: GlobalAppWall.inactiveFBPages[indexPath.row].pageID) {
                if objToDelete.count == 1 {
                    GlobalAppWall.managedContext.deleteObject(objToDelete[0])
                   
                } 
            }
        default: break
        }
        
        do {
            try GlobalAppWall.managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
}
