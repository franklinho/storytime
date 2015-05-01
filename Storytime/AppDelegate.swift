//
//  AppDelegate.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit
import CoreData
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {

    var window: UIWindow?
    var mask : CALayer?
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var vc : UIViewController?
    var mostRecentUserInfo : [NSObject : AnyObject]?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        
        Fabric.with([Crashlytics()])

        Parse.setApplicationId("N1IU3qQJhUOkP2E93hNyISSrJu0uUsMsFjmG23bO", clientKey: "RQO2yFnxsSKsMRzUcPzhqvgGx438fzJhBFB2Jgin")
        PFUser.enableRevocableSessionInBackground()
        PFFacebookUtils.initializeFacebook()
        PFTwitterUtils.initializeWithConsumerKey("C32fxiLVtibIsevg8HT2cDVpw", consumerSecret: "QDWMrdBILOAEtAGbzzVKTHGszf5V96kxsFYEGqAZCR8lhdq15a")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let userNotificationTypes = (UIUserNotificationType.Alert |
            UIUserNotificationType.Badge |
            UIUserNotificationType.Sound);
        
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
//        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//            UIUserNotificationTypeBadge |
//            UIUserNotificationTypeSound);
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//            categories:nil];
//        [application registerUserNotificationSettings:settings];
//        [application registerForRemoteNotifications];
        
        
//        self.mask = CALayer()
//
//
//        self.mask!.contents = UIImage(named: "storyweave_logo.png")!.CGImage
//        
//        
//        self.mask!.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
//        self.mask!.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        self.mask!.position = CGPoint(x: self.screenSize.width/2, y: self.screenSize.height/2)
//        
//        var storyboard = UIStoryboard(name: "Main", bundle: nil)
//        self.vc = storyboard.instantiateViewControllerWithIdentifier("TabBarController") as UIViewController
//        
//        self.vc!.view.layer.mask = self.mask
//        self.window?.rootViewController = self.vc
//        self.vc!.view.alpha = 0
//        
//        self.animateMask()
//        
//        self.window!.backgroundColor = UIColor(red: 41/255, green: 37/255, blue: 55/255, alpha: 1)
//        
//        self.window!.makeKeyAndVisible()
//        
        let defaults = NSUserDefaults.standardUserDefaults()
        let installation = PFInstallation.currentInstallation()
        
        if defaults.objectForKey("storyNotificationsOn") == nil {
            defaults.setBool(true, forKey: "storyNotificationsOn")
            installation["storyNotificationsOn"] = true
        }
        
        if defaults.objectForKey("commentNotificationsOn") == nil {
            defaults.setBool(true, forKey: "commentNotificationsOn")
            installation["commentNotificationsOn"] = true
        }
        
        if installation["storyNotificationsOn"] == nil {
            installation["storyNotificationsOn"] = true
        }
        
        if installation["commentNotificationsOn"] == nil {
            installation["commentNotificationsOn"] = true
        }
        
        
        
        installation.saveInBackground()
        
        var systemColor = UIColor(red: 41.0/255.0, green: 37.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        
        UINavigationBar.appearance().backgroundColor = UIColor(red: 49.0/255.0, green: 49.0/255.0, blue: 78.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = systemColor
        UIBarButtonItem.appearance().tintColor = systemColor
        UINavigationBar.appearance().titleTextAttributes =
            [NSForegroundColorAttributeName: systemColor]
        
        UITabBar.appearance().selectedImageTintColor = systemColor
        println("Launch Options : \(launchOptions)")
        if launchOptions != nil {
            var notificationPayload : NSDictionary = launchOptions![UIApplicationLaunchOptionsRemoteNotificationKey] as! NSDictionary
            
            var storyID = notificationPayload["storyID"] as! String
            var comment = notificationPayload["comment"]
            var targetStory : PFObject = PFObject(withoutDataWithClassName: "Story", objectId: storyID)
            
            targetStory.fetchIfNeededInBackgroundWithBlock {
                (user, error) -> Void in
                var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as! StoryViewController
                storyVC.story = targetStory
                storyVC.refreshEventsForStory()
                
                var rootViewController = self.window!.rootViewController as! HamburgerViewController
                var rankingVC : UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RankingNavigationViewController") as! UINavigationController

                rootViewController.activeViewController = rankingVC
                var navController = rootViewController.activeViewController as! UINavigationController
                navController.pushViewController(storyVC, animated: true)
                if comment != nil {
                    if comment as! String == "true" {
                        storyVC.displayStoryComments()
                    }
                }
            }
            
            
            
        }
        


        
//        NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//        
//        // Create a pointer to the Photo object
//        NSString *photoId = [notificationPayload objectForKey:@"p"];
//        PFObject *targetPhoto = [PFObject objectWithoutDataWithClassName:@"Photo"
//        objectId:photoId];
//        
//        // Fetch photo object
//        [targetPhoto fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        // Show photo view controller
//        if (!error && [PFUser currentUser]) {
//        PhotoVC *viewController = [[PhotoVC alloc] initWithPhoto:object];
//        [self.navController pushViewController:viewController animated:YES];
//        }
//        }];
        
        
//        var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("HamburgerViewController") as! UIViewController
//        window?.rootViewController = vc
        
        return true
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
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())

    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "franklinho.Storytime" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Storytime", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Storytime.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
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
        var managedObjectContext = NSManagedObjectContext()
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
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        var rootViewController = self.window!.rootViewController as! UITabBarController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if url.host == "twitterLogInSuccessful" {
            if (PFUser.currentUser() != nil && PFUser.currentUser()!["profileName"] == nil) {
                var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
                rootViewController.presentViewController(createProfileVC, animated: true, completion: nil)
            }
            
        }
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    
    func animateMask() {
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "bounds")
        keyFrameAnimation.delegate = self
        keyFrameAnimation.duration = 1.5
        keyFrameAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)]
        let initialBounds = NSValue(CGRect: mask!.bounds)
        let secondBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: mask!.bounds.width * 2, height: mask!.bounds.height * 2))
        let finalBounds = NSValue(CGRect: CGRect(x: 0, y: 0, width: mask!.bounds.width * 30, height: mask!.bounds.height * 20))
        keyFrameAnimation.values = [initialBounds, secondBounds, finalBounds]
        keyFrameAnimation.keyTimes = [0, 0.5, 1.5]
        
        
        self.mask!.addAnimation(keyFrameAnimation, forKey: "bounds")
        self.mask!.bounds = CGRect(x: 0, y: 0, width: mask!.bounds.width * 20, height: mask!.bounds.width * 20)
        
        UIView.animateWithDuration(1.5,
            delay: 0.0,
            options: nil,
            animations: {
                self.vc!.view.alpha = 1.0
            },
            completion: {
                finished in
        })
        
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        if PFUser.currentUser() != nil {
            installation["user"] = PFUser.currentUser()!.objectId!
        }
        installation.addUniqueObject("global", forKey: "channels")
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("Application state: \(application.applicationState.rawValue)")
        println("UserInfo : \(userInfo)")
        
        self.mostRecentUserInfo = userInfo
        var state = application.applicationState.rawValue
        
        if (state == 0) {
            //app is in foreground
            //the push is in your control
//            var rootViewController = self.window!.rootViewController as! HamburgerViewController
//            rootViewController.activeViewController = rootViewController.viewControllers.first
//            var navController = rootViewController.activeViewController as! UINavigationController
//            var currentController = navController.topViewController
            var alertString = userInfo["aps"]!["alert"]
            var notificationAlertView = UIAlertView(title: "Storytime", message: alertString as! String, delegate: self, cancelButtonTitle: "Dismiss", otherButtonTitles: "View")
            notificationAlertView.delegate = self
            notificationAlertView.show()
//            PFPush.handlePush(userInfo)
        } else {
            //app is in background:
            //iOS is responsible for displaying push alerts, banner etc..
            self.activatePushResponse(self.mostRecentUserInfo!)
        }
        
        
        
        
    }
    

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Failed to register for remote notification. \(error.description)")
    }

    func activatePushResponse(userInfo : [NSObject : AnyObject]) {
        var storyID = userInfo["storyID"]
        var comment = userInfo["comment"]
        println("\(storyID)")
        var targetStory : PFObject = PFObject(withoutDataWithClassName: "Story", objectId: "\(storyID!)")
        
        targetStory.fetchIfNeededInBackgroundWithBlock {
            (user, error) -> Void in
            var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as! StoryViewController
            storyVC.story = targetStory
            storyVC.refreshEventsForStory()
            
            var rootViewController = self.window!.rootViewController as! HamburgerViewController
            var rankingVC : UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("RankingNavigationViewController") as! UINavigationController
            rootViewController.activeViewController = rankingVC
            var navController = rootViewController.activeViewController as! UINavigationController
            navController.pushViewController(storyVC, animated: true)
            if comment != nil {
                if comment  as! String == "true"{
                    storyVC.displayStoryComments()
                }
            }
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            println("Dismiss button tapped")
        } else {
            println("View button tapped")
            self.activatePushResponse(self.mostRecentUserInfo!)
        }
    }
    
}

