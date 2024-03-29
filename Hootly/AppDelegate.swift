//
//  AppDelegate.swift
//  Hootly
//
//  Created by Quinton Petty on 1/24/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var pushToken: String?
    let locationManager = CLLocationManager()
    
    let userIDStorageKey = "HootlyUserID"
    let pushNotificationStorageKey = "SentPUSHNotification"
    let locationScreenShown = "LocationScreenShown"
    
    var hootToShow: Hoot? = nil
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        var types: UIUserNotificationType = UIUserNotificationType.Badge |
            UIUserNotificationType.Alert |
            UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings( forTypes: types, categories: nil )
        
        application.registerUserNotificationSettings( settings )
        application.registerForRemoteNotifications()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var firstVC: UIViewController
        
        if let userIDData = NSUserDefaults.standardUserDefaults().dataForKey(self.locationScreenShown) {
            firstVC = storyboard.instantiateViewControllerWithIdentifier("IntialViewController") as! UIViewController
        } else {
            firstVC = storyboard.instantiateViewControllerWithIdentifier("LocationScreen") as! UIViewController
        }
        
        self.window?.rootViewController = firstVC
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    var hootlyID: String? {
        get {
            var id: String? = nil
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if let userIDData = defaults.dataForKey(self.userIDStorageKey) {
                id = NSKeyedUnarchiver.unarchiveObjectWithData(userIDData) as? String
                
                if defaults.dataForKey(self.pushNotificationStorageKey) == nil {
                    if let token = self.pushToken {
                        HootAPIToCoreData.postPUSHToken(id!, token: token, completed: self.tokenResponse)
                    }
                }
            } else {
                HootAPIToCoreData.getHootID { (id) -> (Void) in
                    if id != nil {
                        let userIDData = NSKeyedArchiver.archivedDataWithRootObject(id!)
                        defaults.setObject(userIDData, forKey: self.userIDStorageKey)
                        defaults.synchronize()
                        NSLog("Setting Hootly ID to: \(id)")
                        
                        if let token = self.pushToken {
                            HootAPIToCoreData.postPUSHToken(id!, token: token, completed: self.tokenResponse)
                        }
                    }
                }
            }
            return id
        }
    }
    
    let tokenResponse = { (success: Bool) -> (Void) in
        let appD = UIApplication.sharedApplication().delegate as! AppDelegate
        if success == true {
            let userIDData = NSKeyedArchiver.archivedDataWithRootObject(NSNumber(bool: true))
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(userIDData, forKey: appD.pushNotificationStorageKey)
            defaults.synchronize()
        } else {
            NSLog("token didn't save")
        }
    }
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        
        var characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        var deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        pushToken = deviceTokenString
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        NSLog("\ndidFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)\n")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NSLog("didReceiveRemoteNotification with dictionary: \(userInfo)")
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        HootAPIToCoreData.resetPUSHNotificationCount { (success) -> (Void) in
            //Check for success if needed, the return value is not important at the moment
        }
        
        if let hoot_id = userInfo["hoot_id"] as? Int {
            HootAPIToCoreData.getSingleHoot(hoot_id) { (returnedHoots) -> (Void) in
                println("Got Hoot:\(hoot_id)")
                return
            }
            
            let fetchReq = NSFetchRequest(entityName: "Hoot")
            fetchReq.predicate = NSPredicate(format: "id == \(hoot_id)");
            
            var error: NSError?
            
            if let results = managedObjectContext?.executeFetchRequest(fetchReq, error: &error) {
                hootToShow = results[0] as? Hoot;
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        hootToShow = nil
    }

    func applicationWillEnterForeground(application: UIApplication) {
        NSLog("App Entered Foreground")
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        NSLog("Application become active")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if let hoot = hootToShow {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let singleHootViewController = storyboard.instantiateViewControllerWithIdentifier("SingleHoot") as! SingleHootViewController
            
            if let navController = self.window?.rootViewController as? UINavigationController {
                NSLog("pushing \(navController)")
                singleHootViewController.hoot = hoot;
                navController.dismissViewControllerAnimated(true, completion: nil)
                navController.pushViewController(singleHootViewController, animated: true)
            }
            
            hootToShow = nil
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "ovl.HootyCD" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Hootly", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Hootly.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}

