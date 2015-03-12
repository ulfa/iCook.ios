//
//  AppDelegate.swift
//  iCook.ios
//
//  Created by Ulf Angermann on 08/03/15.
//  Copyright (c) 2015 Ulf Angermann. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let SERVICE = "icook"
    let USERACCOUNT = "userAccout"


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        if checkSettings(loadSettings()) != 0 {
            println(".......... error checking settings")
            if let tabBarController = self.window!.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
                
            }
        }

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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadSettings() -> Dictionary<String, String> {
        var settings: Dictionary<String, String> = Dictionary()
        let (data, error) = Locksmith.loadDataForUserAccount(USERACCOUNT, inService: SERVICE)
        if data != nil {
            settings = data as Dictionary
        }
        return settings
    }
    
    func checkSettings(settings: Dictionary<String, String>) -> Int{
        if settings.isEmpty {
            return -1
        } else if settings["locationURI"] == nil  {
            return -2
        } else if settings["account"] == nil {
            return -3
        } else if settings["password"] == nil {
            return -4
        }
        return 0
    }



}

