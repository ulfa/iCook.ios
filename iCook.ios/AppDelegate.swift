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
    let USERACCOUNT = "userAccount"
    let LOCATION = "locationURI"
    let ACCOUNT = "account"
    let PASSWORD = "password"

    @objc func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)  -> Bool {
        
        if try checkSettings(loadSettings()) != 0 {
            if let tabBarController = self.window!.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
                
            }
        }
        //
        // init of the notificationservice
        //
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print(token)
        
        print("Device Token:", token)
        
        let parameters = ["device_token": token]
        let settings = loadSettings()
        let headers = createHeader(settings, account: settings[ACCOUNT]!, passwd: settings[PASSWORD]!)
        let url = settings[LOCATION]! + "/apns/register"
        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).response{
            response in
            print(response)
        }
    }
    
    func createHeader(_ settings: Dictionary<String, String>, account: String, passwd: String) -> [String:String] {
        let headers = [
            "Authorization": "Basic " + createAccount(settings[ACCOUNT]!, passwd: settings[PASSWORD]!),
            "Accept": "application/json"
        ]
        return headers
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Device token for push notifications: FAIL -- ")
        print(error.localizedDescription)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // display the userInfo
        if let notification = userInfo["aps"] as? NSDictionary,
            let alert = notification["alert"] as? String {
                let alertCtrl = UIAlertController(title: "iCook", message: alert as String, preferredStyle: UIAlertControllerStyle.alert)
                alertCtrl.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                // Find the presented VC...
                var presentedVC = self.window?.rootViewController
                while (presentedVC!.presentedViewController != nil)  {
                    presentedVC = presentedVC!.presentedViewController
                }
                presentedVC!.present(alertCtrl, animated: true, completion: nil)
                
                // call the completion handler
                // -- pass in NoData, since no new data was fetched from the server.
                completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("didReceiveRemoteNotification")
        if let msg = userInfo["msg"] as? NSObject {
            print(msg)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadSettings() -> Dictionary<String, String> {
        var settings: Dictionary<String, String> = Dictionary()
        do {
            print(self.USERACCOUNT)
            let data = Locksmith.loadDataForUserAccount(userAccount: self.USERACCOUNT)
                if data != nil && !data!.isEmpty {
                    settings = data! as! Dictionary<String, String>
                } else {
                    settings = [LOCATION: "", ACCOUNT: "", PASSWORD: ""]
            }
        }
        return settings
    }
    
    func checkSettings(_ settings: Dictionary<String, String>) -> Int{
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
    
    func createAccount(_ account: String, passwd: String) -> String {
        let plainString = account + ":" + passwd as NSString
        let plainData = plainString.data(using: String.Encoding.utf8.rawValue)
        let base64String =  plainData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String!
    }




}

