//
//  AppDelegate.swift
//  iCook.ios
//
//  Created by Ulf Angermann on 08/03/15.
//  Copyright (c) 2015 Ulf Angermann. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let SERVICE = "icook"
    let USERACCOUNT = "userAccout"
    let LOCATION = "locationURI"
    let ACCOUNT = "account"
    let PASSWORD = "password"

    @objc func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)  -> Bool {
        
        if try checkSettings(loadSettings()) != 0 {
            if let tabBarController = self.window!.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
                
            }
        }
        //
        // init of the notificationservice
        //
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        return true
    }
    
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        
        print( deviceTokenString )
        let parameters = ["device_token": deviceTokenString]
        let settings = loadSettings()
        let headers = createHeader(settings, account: settings[ACCOUNT]!, passwd: settings[PASSWORD]!)
        let url = settings[LOCATION]! + "/apns/register"
        Alamofire.request(.POST, url, parameters: parameters, headers: headers).response{
            (request, response, data, error) in
            print(response)
        }
    }
    
    func createHeader(settings: Dictionary<String, String>, account: String, passwd: String) -> [String:String] {
        let headers = [
            "Authorization": "Basic " + createAccount(settings[ACCOUNT]!, passwd: settings[PASSWORD]!),
            "Accept": "application/json"
        ]
        return headers
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ")
        print(error.description)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // display the userInfo
        if let notification = userInfo["aps"] as? NSDictionary,
            let alert = notification["alert"] as? String {
                let alertCtrl = UIAlertController(title: "iCook", message: alert as String, preferredStyle: UIAlertControllerStyle.Alert)
                alertCtrl.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                // Find the presented VC...
                var presentedVC = self.window?.rootViewController
                while (presentedVC!.presentedViewController != nil)  {
                    presentedVC = presentedVC!.presentedViewController
                }
                presentedVC!.presentViewController(alertCtrl, animated: true, completion: nil)
                
                // call the completion handler
                // -- pass in NoData, since no new data was fetched from the server.
                completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("didReceiveRemoteNotification")
        if let msg = userInfo["msg"] as? NSObject {
            print(msg)
        }
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
        do {
            let data =  try Locksmith.loadDataForUserAccount(USERACCOUNT)
                if data != nil && !data!.isEmpty {
                    settings = data! as! Dictionary<String, String>
                } else {
                    settings = [LOCATION: "", ACCOUNT: "", PASSWORD: ""]
            }
        } catch let error as NSError {
            print(error)
        }
        return settings
    }
    
    func checkSettings(settings: Dictionary<String, String>) -> Int{
        if settings.isEmpty {
            return -1
        } else if settings[LOCATION] == nil  {
            return -2
        } else if settings[ACCOUNT] == nil {
            return -3
        } else if settings[PASSWORD] == nil {
            return -4
        }
        return 0
    }
    
    func createAccount(account: String, passwd: String) -> String {
        let plainString = account + ":" + passwd as NSString
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String =  plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))
        return base64String!
    }




}

