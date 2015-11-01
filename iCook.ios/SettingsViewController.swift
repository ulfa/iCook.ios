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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let settings = loadSettings() as Dictionary<String, String>
        passwordText.secureTextEntry = true
        locationText.text = settings[appDelegate.LOCATION]
        accountTest.text = settings[appDelegate.ACCOUNT]
        passwordText.text = settings[appDelegate.PASSWORD]
        self.passwordText.delegate = self;
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveLocationURI(sender: UITextField) {
    }
    
    @IBAction func saveAccount(sender: UITextField) {
    }
    
    @IBAction func savePassword(sender: UITextField) {
            settings = [appDelegate.LOCATION: locationText.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()),
                        appDelegate.ACCOUNT: accountTest.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()),
                        appDelegate.PASSWORD: sender.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        ]
                saveSettings(settings)
    }
    
    
    func saveSettings(settings: Dictionary<String, String>) {
        do {
            try Locksmith.updateData(settings, forUserAccount: appDelegate.USERACCOUNT)
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func loadSettings() -> Dictionary<String, String> {
        var settings: Dictionary<String, String> = Dictionary()
        let data = Locksmith.loadDataForUserAccount(appDelegate.USERACCOUNT)
        if data != nil {
            settings = data! as! Dictionary<String, String>
        } else {
            do {
                settings = [appDelegate.LOCATION: "", appDelegate.ACCOUNT: "", appDelegate.PASSWORD: ""]
                try Locksmith.saveData(settings, forUserAccount: appDelegate.USERACCOUNT)
            } catch let error as NSError {
                print(error.description)
            }
        }

        return settings

    }
    
    @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    

}