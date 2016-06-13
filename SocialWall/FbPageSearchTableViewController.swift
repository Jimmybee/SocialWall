//
//  FbPageSearchTableViewController.swift
//  SocialWall
//
//  Created by James Birtwell on 21/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

import UIKit
import Accounts
import CoreData

protocol PageSearchDelegate {
    func updateDetail (page: FacebookPage)
}

class FbPageSearchTableViewController: UITableViewController {
    
    var pagesFound = [FacebookPage]()
    var delegate: PageSearchDelegate!
    
    let searchController = UISearchController(searchResultsController: nil)


    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.searchController.searchBar.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        makeSearch(searchText)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pagesFound.count
    }
 
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("myCell", forIndexPath: indexPath)

            // Configure the cell...
            cell.textLabel?.text  = pagesFound[indexPath.row].pageName
            return cell
            
        }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchController.active = false
        pagesFound[indexPath.row].editSave()
        self.dismissViewControllerAnimated(false, completion: nil)
        
        delegate.updateDetail(pagesFound[indexPath.row])
    }
    
    //MARK: Search Methods
    let fbSearch = FacebookSearch()
    
    func makeSearch(searchString: String){
        if let accessToken = facebookAccount?.credential.oauthToken {
            fbSearch.httpSearch(searchString, accessToken: accessToken, handler: handleFbPageSearch)
        } else {
            
            let accountStore = ACAccountStore()
            let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierFacebook)
            let postingOptions = [ACFacebookAppIdKey:
                "674033149402261", ACFacebookPermissionsKey: [], ACFacebookAudienceKey: ACFacebookAudienceFriends]
            
            
            accountStore.requestAccessToAccountsWithType(accountType, options: postingOptions as [NSObject : AnyObject], completion: { (success, error) in
                let accountsArray =
                    accountStore.accountsWithAccountType(accountType)
                if accountsArray == nil {
                    print("no accounts")
                } else {
                    if accountsArray.count > 0 {
                        facebookAccount = accountsArray[0] as? ACAccount
                        self.makeSearch(searchString)
                        
                    }
                }
            })
        }
    }
    
    func handleFbPageSearch (pages: [FacebookPage]) {
        print(pages.count)
        pagesFound = pages
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            
        })
        
    }

}

extension FbPageSearchTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
