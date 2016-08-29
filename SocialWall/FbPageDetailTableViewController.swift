//
//  FbPageDetailTableViewController.swift
//  SocialWall
//
//  Created by James Birtwell on 21/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import CoreData

extension FbPageDetailTableViewController: PageSearchDelegate {
    func updateDetail (page: FacebookPage)
    {
        self.page = page
        GlobalAppWall.activeSocialWall.pages.append(page)
        self.updateUI()
        GlobalAppWall.activeSocialWall.saveWall()
        GlobalAppWall.wallNeedsLoading = true

    }
}

class FbPageDetailTableViewController: UITableViewController {
    
    var page: FacebookPage!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var activeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    func updateUI(){
        if page != nil {
            nameLabel.text = page.pageName
            idLabel.text = String(page.pageLink)
            activeSwitch.on = page.active
        } else {
            performSegueWithIdentifier(Constants.kSearchSegue, sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //MARK: Navigation
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)

        if (self.isMovingFromParentViewController()){
            page.active = activeSwitch.on
            if activeSwitch.on == false {
                if let index = GlobalAppWall.activeSocialWall.pages.indexOf({ (activePage) -> Bool in
                    self.page.pageID == activePage.pageID
                    
                }){
                    GlobalAppWall.activeSocialWall.pages.removeAtIndex(index)
                    GlobalAppWall.inactiveFBPages.append(self.page)
                    GlobalAppWall.wallNeedsLoading = true
                }
            } else {
                
                if let index = GlobalAppWall.inactiveFBPages.indexOf({ (inactivePage) -> Bool in
                    self.page.pageID == inactivePage.pageID
                    
                }){
                    GlobalAppWall.inactiveFBPages.removeAtIndex(index)
                    GlobalAppWall.activeSocialWall.pages.append(self.page)
                    GlobalAppWall.wallNeedsLoading = true

                }
            }
            
            GlobalAppWall.activeSocialWall.saveWall()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.kSearchSegue  {
            if let dvc = segue.destinationViewController as? FbPageSearchTableViewController {
                dvc.delegate = self
            }
        }
    }
    
    struct Constants {
        static let kSearchSegue = "search"
    }
    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView === self.tableView {
//            return 0
//        } else {
//            return searchResults.count
//        }
//    }

//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)
//
//        // Configure the cell...
//
//        return cell
//    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
