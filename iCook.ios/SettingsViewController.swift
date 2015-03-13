//
//  SettingsViewController.swift
//  iCook.ios
//
//  Created by Ulf Angermann on 11/03/15.
//  Copyright (c) 2015 Ulf Angermann. All rights reserved.
//

import UIKit
import Alamofire

class SettingsViewController: UITableViewController, UITextFieldDelegate{
    
    @IBOutlet var locationText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var accountTest: UITextField!
    

    let SERVICE = "icook"
    let USERACCOUNT = "userAccout"
    let LOCATION = "locationURI"
    let ACCOUNT = "account"
    let PASSWORD = "password"
    
    var settings: Dictionary<String, String> = Dictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var settings = loadSettings() as Dictionary<String, String>
        passwordText.secureTextEntry = true
        locationText.text = settings[LOCATION]
        accountTest.text = settings[ACCOUNT]
        passwordText.text = settings[PASSWORD]
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
            settings = [LOCATION: locationText.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()),
                        ACCOUNT: accountTest.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()),
                        PASSWORD: sender.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        ]
            saveSettings(settings)
    }
    
    func saveSettings(settings: Dictionary<String, String>) -> NSError? {
        let error = Locksmith.updateData(settings, forUserAccount: USERACCOUNT, inService: SERVICE)
        return error
    }
    
    func loadSettings() -> Dictionary<String, String> {
        var settings: Dictionary<String, String> = Dictionary()
        let (data, error) = Locksmith.loadDataForUserAccount(USERACCOUNT, inService: SERVICE)
        if data != nil {
            settings = data as Dictionary
        } else {
            settings = [LOCATION: "", ACCOUNT: "", PASSWORD: ""]
            let error = Locksmith.saveData(settings, forUserAccount: USERACCOUNT, inService: SERVICE)
        }
        return settings

    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    

}