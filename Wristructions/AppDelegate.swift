//
//  AppDelegate.swift
//  Wristructions
//
//  Created by Chris Meehan on 8/27/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
// Hi testers

import UIKit
import CoreData
import CoreDataAccessFramework
import EventKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appReceived:Int = 0
    var watchWantsToSchdedual:Int = 0 // Keep track of how many local notifs we've called.
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // We want those little dots on the bottom when we have a pageController.
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGrayColor()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.redColor()
        
        // Setup how our local notifications will be.
        let notificationSettings2 = UIUserNotificationSettings(
            forTypes: UIUserNotificationType.Sound,
            categories: nil)
        application.registerUserNotificationSettings(notificationSettings2)
        
        return true
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: ([NSObject : AnyObject]?) -> Void) {
        if let value: AnyObject = userInfo?["scheduleLocalNotification"] where value as! Bool {

            watchWantsToSchdedual = watchWantsToSchdedual + Int(1)
            // Then we are creating a new notification.
            let notification = UILocalNotification()
            notification.category = "wristructionUserNotifCatID"
            notification.alertBody = userInfo?["alertBody"] as? String
            notification.fireDate = userInfo?["fireDate"] as? NSDate
            notification.soundName = userInfo?["soundName"] as? String
            application.scheduleLocalNotification(notification)
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        appReceived = appReceived + Int(1)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataAccess.sharedInstance.saveContext()
    }
}

