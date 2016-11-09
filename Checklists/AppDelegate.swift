//
//  AppDelegate.swift
//  Checklists
//
//  Created by Garrett Crawford on 12/28/15.
//  Copyright © 2015 Noox. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // consider the app delegate to be the 'top-level' object in the app
    // therefore it makes sense to make it the owner of the data model
    let dataModel = DataModel()

    // gets called as soon as the app starts up (of course)
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        // looks at the window property to find the UIWindow object that contains the storyboard
        // UIWindow is the top level container for all app's views
        // 'window!' 'force unwraps' the optional with a '!'
        // force unwrap an optional if you know for sure that the optional will not be nil
        // when you use it
        let navigationController = window!.rootViewController as! UINavigationController
        let controller = navigationController.viewControllers[0] as! AllListsViewController
        
        // makes the 'AllListsViewController' data model reference point to the same data model
        // reference defined in the app delegate
        controller.dataModel = dataModel
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication)
    {
        saveData()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    // this method is invoked when the local notification is posted and the app is still running
    // or in a suspended state in the background
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification)
    {
        print("didReceiveLocalNotification \(notification)")
    }

    func applicationWillTerminate(application: UIApplication)
    {
        saveData()
    }
    
    func saveData()
    {
        dataModel.saveChecklists()
    }


}

