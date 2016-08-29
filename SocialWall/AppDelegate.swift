//
//  AppDelegate.swift
//  SocialWall
//
//  Created by James Birtwell on 10/05/2016.
//  Copyright © 2016 James Birtwell. All rights reserved.
//

struct GlobalAppWall {
    static let kCoreDataId = "main"
    static var activeSocialWall: SocialWall!
    static var inactiveFBPages = [FacebookPage]()
    static let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    static var wallNeedsLoading = true
    static var fetchingData = 0
    static var screenConnected:Bool {
        if (UIScreen.screens().count == 1) {
            return false
        } else {
            return true
        }
    }
}

import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let kFacebookAppID = "674033149402261"

    var window: UIWindow?
    var secondaryWindow: UIWindow?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Subscribing to a UIScreenDidConnect/DisconnectNotification to react to changes in the status of connected screens.
       
        let screenConnectionStatusChangedNotification = NSNotificationCenter.defaultCenter()
        screenConnectionStatusChangedNotification.addObserver(self, selector:  #selector(self.screenConnectionStatusChanged), name:UIScreenDidConnectNotification, object:nil)
        screenConnectionStatusChangedNotification.addObserver(self, selector: #selector(self.screenConnectionStatusChanged), name:UIScreenDidDisconnectNotification, object:nil)
        
        //Initial check on how many screens are connected to the device on launch of the application.
        if (UIScreen.screens().count > 1) {
            self.screenConnectionStatusChanged()
        }
        
        
        checkLoadWall()
        // Override point for customization after application launch.
        
        return true
    }
    
    func checkLoadWall() {
        if let socialWallObject = CoreDataHelpers.fetchObjects(SocialWall.Keys.kEntityName, predicate: GlobalAppWall.kCoreDataId) {
            print("walls = \(socialWallObject.count)")
            GlobalAppWall.activeSocialWall = SocialWall(object: socialWallObject[0])
            print("currentHashtag = \(GlobalAppWall.activeSocialWall.currentHashtag)")
            if  let objects = CoreDataHelpers.fetchObjects(FacebookPage.PageKeys.kEntityName) {
                print("pages = \(objects.count)")
                for page in objects {
                    if let pageName = page.valueForKey(FacebookPage.PageKeys.kName) as? String  {
                        if !GlobalAppWall.activeSocialWall.pages.contains({aPage in aPage.pageName == pageName}) {
                            GlobalAppWall.inactiveFBPages.append(FacebookPage(object: page))
                        }
                    }
                }
            }
        } 
    }

    //Managing connection and disconnection of screens.
    func screenConnectionStatusChanged () {
        if GlobalAppWall.screenConnected {
            print("connected")
        } else {
            print("not connected")
        }
        if (UIScreen.screens().count == 1) {
            secondaryWindow!.rootViewController = nil
            
        }   else {
            let screens : Array = UIScreen.screens()
            let newScreen : AnyObject! = screens.last
            
            secondaryScreenSetup(newScreen as! UIScreen)
            let storyboard = UIStoryboard(name: "SecondScreen", bundle:nil)
            if let rvc = storyboard.instantiateViewControllerWithIdentifier("SecondScreen") as? SecondaryViewController {
            secondaryWindow!.rootViewController = rvc
            secondaryWindow!.makeKeyAndVisible()
            }
        }
        
    }
    
    //Here we set up the secondary screen.
    func secondaryScreenSetup (screen : UIScreen) {
        let newWindow : UIWindow = UIWindow(frame: screen.bounds)
        newWindow.screen = screen
        newWindow.hidden = false
        
        secondaryWindow = newWindow
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Split view
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? FbPagesTableViewController {
//                if topAsDetailController == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    //If we don't do this, detail1 will open as the first view when run on iPhone, comment and see
                    return true
//                }
            }
        }
        return false
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "JB.SocialWall" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SocialWall", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as! NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

