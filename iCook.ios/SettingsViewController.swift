//
//  SettingsViewController.swift
//  iCook.ios
//
//  Created by Ulf Angermann on 11/03/15.
//  Copyright (c) 2015 Ulf Angermann. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith

class SettingsViewController: UITableViewController, UITextFieldDelegate{
    
    @IBOutlet var locationText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var accountTest: UITextField!
        
    var settings: Dictionary<String, String> = Dictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let settings = loadSettings() as Dictionary<String, String>
        passwordText.isSecureTextEntry = true
        locationText.text = settings[appDelegate.LOCATION]
        accountTest.text = settings[appDelegate.ACCOUNT]
        passwordText.text = settings[appDelegate.PASSWORD]
        self.passwordText.delegate = self;
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveLocationURI(_ sender: UITextField) {
        print("saveLocationURI")
    }
    
    @IBAction func saveAccount(_ sender: UITextField) {
        print("saveAccount")
    }
    
    @IBAction func savePassword(_ sender: UITextField) {
        print("savePassword")
        print(settings)
        settings = [appDelegate.LOCATION: locationText.text!.trimmingCharacters(in: CharacterSet.whitespaces),
                    appDelegate.ACCOUNT: accountTest.text!.trimmingCharacters(in: CharacterSet.whitespaces),
                    appDelegate.PASSWORD: sender.text!.trimmingCharacters(in: CharacterSet.whitespaces)
                    ]
        saveSettings(settings)
    }
    
    
    func saveSettings(_ settings: Dictionary<String, String>) {
        print("save settings")
        print(settings)
        print(appDelegate.USERACCOUNT)
        do {
            try Locksmith.saveData(data: settings, forUserAccount: appDelegate.USERACCOUNT)
        } catch let error as Error {
            try! Locksmith.updateData(data: settings, forUserAccount: appDelegate.USERACCOUNT)
        }
    }
    
    func loadSettings() -> Dictionary<String, String> {
        print("------------- loadSettings() ---------------------")
        var settings: Dictionary<String, String> = Dictionary()
        let data = Locksmith.loadDataForUserAccount(userAccount: appDelegate.USERACCOUNT)
        if data != nil {
            settings = data! as! Dictionary<String, String>
        } else {
            do {
                settings = [appDelegate.LOCATION: "", appDelegate.ACCOUNT: "", appDelegate.PASSWORD: ""]
                try Locksmith.saveData(data: settings, forUserAccount: appDelegate.USERACCOUNT)
            } catch let error as NSError {
                print(error.description)
            }
        }
        print("out of settingsView")
        return settings
        print("-------------------")

    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    

}
