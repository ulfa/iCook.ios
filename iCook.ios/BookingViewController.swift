//
//  BookingViewController.swift
//  iCook.ios
//
//  Created by Ulf Angermann on 08/03/15.
//  Copyright (c) 2015 Ulf Angermann. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BookingViewController: UITableViewController{

    var baseURI: String = ""
    var account: String = ""
    let url = "/booking/index_json"
    let bookingUrl = "/booking/book"
    let stornoUrl = "/booking/storno"
    let requestUrl = "/booking/request"
    var bookingCellIdentifier = "bookingCell"
    var menus: [Menu] = []
    let iconHaken = UIImage(named: "icon_haken.png") as UIImage?
    let iconAnfrage = UIImage(named: "anfrage.png") as UIImage?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view, typically from a nib.
        //customizeView()
        tableView.delegate = self
        tableView.dataSource = self
        super.refreshControl = UIRefreshControl()
        super.refreshControl?.addTarget(self, action: Selector("refresh:"), forControlEvents: UIControlEvents.ValueChanged)
        let settings = appDelegate.loadSettings()
        baseURI = settings[appDelegate.LOCATION]!
        account = createAccount(settings[appDelegate.ACCOUNT]!, passwd: settings[appDelegate.PASSWORD]!)
        initBookings()
    }

    func customizeView() {
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.backgroundColor = UIColor.lightTextColor()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.tabBarController?.tabBar.barTintColor = UIColor.redColor()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(bookingCellIdentifier, forIndexPath: indexPath) as! BookingCell
        cell.bookinDate.text = menus[indexPath.row].convertDate()
        cell.bookingTitle.text = menus[indexPath.row].title
        cell.bookingTitle.font = UIFont(name:"HelveticaNeue-Bold", size: 24)
        
        cell.bookingDetails.text = menus[indexPath.row].details
        cell.bookingDetails.font = UIFont(name:"HelveticaNeue -Bold", size: 18)
    
        if menus[indexPath.row].allreadybooked() {
            cell.bookedImage?.image = iconHaken
        } else if menus[indexPath.row].isRequester() {
            cell.bookedImage?.image = iconAnfrage
        } else {
           cell.bookedImage?.image = nil
        }
        if !menus[indexPath.row].isInTime()  {
            createStruckOut(menus[indexPath.row].details, label: cell.bookingDetails)
            createStruckOut(menus[indexPath.row].title, label: cell.bookingTitle)
        }
        
        cell.bookingFreeMeals.text = menus[indexPath.row].slots + " : " + menus[indexPath.row].countGiven
        cell.bookingFreeMeals.font = UIFont(name:"HelveticaNeue-Bold", size: 12)
        cell.bookingFreeMeals.textColor = UIColor.lightGrayColor()
        
        return cell
    }
    
    func createStruckOut(text: String, label: UILabel)  {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        label.attributedText = attributeString
    }
    
    //UITableViewDelegate
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        _ = tableView.cellForRowAtIndexPath(indexPath) as! BookingCell?
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func refresh(sender:AnyObject) {
        initBookings()
        super.refreshControl?.endRefreshing()
    }
    
    func initBookings() {
        let headers = [
            "Authorization": "Basic " + self.account,
            "Accept": "application/json"
        ]
        
        Alamofire.request(.GET, baseURI + url, headers: headers)
            .responseJSON {response in
                switch response.result {
                    case .Success(let data):
                        let json = JSON(data)
                        let eater = json["eater_id"].stringValue
                        self.menus = self.createMenus(json["menus"], eater: eater)
                        self.tableView.reloadData()
                    case .Failure(let error):
                        print(response.debugDescription)
                        print("Request failed with error: \(error)")
                }
            }
    }
    
    func createMenus(data: JSON, eater: String) -> [Menu]{
        var menus: [Menu] = []
        for (_, subJson) in data {
            menus.append(createMenu(subJson, eater: eater))
        }
        return menus
    }
    
    func createBookings(data: JSON) -> [String] {
        var bookings: [String] = []
        for (_, subJson)  in data {
            bookings.append(subJson["eater"].stringValue)
        }
        return bookings
    }

    func createRequesters(data: JSON) -> [String] {
        var requesters: [String] = []
        for (_, subJson) in data {
            requesters.append(subJson["requester"].stringValue)
        }
        return requesters
    }

    func createMenu(data: JSON, eater: String) -> Menu {
        let id  = data["menu"]["id"].stringValue
        let date = data["menu"]["date"].stringValue
        let slots = data["menu"]["slots"].stringValue
        let countGiven = data["free_slots"].stringValue
        let title = data["dish"]["title"].stringValue
        let details = data["dish"]["details"].stringValue
        let vegetarian =  data["dish"]["vegetarian"].boolValue
        let bookings = createBookings(data["bookings"])
        let eaterNames = data["eater_name"].stringValue
        let requesters = createRequesters(data["requesters"])
        return Menu(id: id, date: date, slots: slots, countGiven: countGiven, title: title, details: details, vegetarian: vegetarian, eater: eater, bookings: bookings, eaterNames: eaterNames, requesters: requesters)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        let stornoAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Stornieren" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in

            let parameters = ["eater-id": self.menus[indexPath.row].eater,
                              "menu-id": self.menus[indexPath.row].id
                             ]
            self.sendRequest(self.baseURI + self.stornoUrl, parameters: parameters)
        })

        let anfrageAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Anfragen" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in

            let parameters = ["eater-id": self.menus[indexPath.row].eater,
                              "menu-id": self.menus[indexPath.row].id
                             ]
            
            self.sendRequest(self.baseURI + self.requestUrl, parameters: parameters)
        })

        let bookingAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Buchen" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            let parameters = ["eater-id": self.menus[indexPath.row].eater,
                              "menu-id": self.menus[indexPath.row].id
                             ]
            
            self.sendRequest(self.baseURI + self.bookingUrl, parameters: parameters)
        })
        
        let esserAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Esser" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.createAllEaterView(self.menus[indexPath.row].eaterNames)
        })
        esserAction.backgroundColor = UIColor.lightGrayColor()
        stornoAction.backgroundColor = UIColor.redColor()
        anfrageAction.backgroundColor = UIColor.redColor()
        bookingAction.backgroundColor = UIColor.blueColor()

        if (self.menus[indexPath.row].allreadybooked() && self.menus[indexPath.row].isInTime()) {
            return [esserAction, stornoAction]
        } else if (Int(self.menus[indexPath.row].countGiven) > 0 && self.menus[indexPath.row].isInTime()) {
            return [esserAction, bookingAction]
        } else if (self.menus[indexPath.row].isInTime()) {
            return [esserAction, anfrageAction]
        }
        return [esserAction]
    }
    
    func sendRequest(url: String, parameters: [String: AnyObject]) {
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic " + self.account
        ]
        Alamofire.request(.POST, url, parameters: parameters).response{
            (request, response, data, error) in
            self.initBookings()
        }
    }
    
    func createAllEaterView(eaterNames: String) {
        let alert = UIAlertController(title: "Esser", message: eaterNames, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func createAccount(account: String, passwd: String) -> String {
        let plainString = account + ":" + passwd as NSString
        let plainData = plainString.dataUsingEncoding(NSUTF8StringEncoding)
        let base64String =  plainData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0))
        return base64String!
    }

    
}