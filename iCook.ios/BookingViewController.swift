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

    let url = "http://localhost:8090/kiezkantine/booking/index_json"
    var bookingCellIdentifier = "bookingCell"
    var menus: [Menu] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.delegate = self
        tableView.dataSource = self
        super.refreshControl = UIRefreshControl()
        super.refreshControl?.addTarget(self, action: Selector("refresh:"), forControlEvents: UIControlEvents.ValueChanged)
        initBookings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(bookingCellIdentifier, forIndexPath: indexPath) as BookingCell
        cell.bookinDate.text = convertDate(menus[indexPath.row].date)
        cell.bookingTitle.text = menus[indexPath.row].title
        cell.bookingTitle.font = UIFont(name:"HelveticaNeue-Bold", size: 24)
        cell.bookingDetails.text = menus[indexPath.row].details
        cell.bookingDetails.font = UIFont(name:"HelveticaNeue -Bold", size: 18)
        cell.bookingDetails.lineBreakMode = .ByWordWrapping
        cell.bookingDetails.numberOfLines = 0
        return cell
    }
    
    func convertDate(date: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy hh:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "GMT")
        var date1 = dateFormatter.dateFromString(date)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.stringFromDate(date1!)
    }
    
    //UITableViewDelegate
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var cell = tableView.cellForRowAtIndexPath(indexPath) as BookingCell?
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
        var lMenus: [Menu] = []
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "Accept": "application/json",
            "REMOTE_USER": "ua"
        ]
        Alamofire.request(.GET, url)
            .responseJSON { (request, response, Json, error) in
                let json = JSON(Json!)
                var eater = json["eater_id"].stringValue
                self.menus = self.createMenus(json["menus"], eater: eater)
                self.tableView.reloadData()
        }
    }
    
    func createMenus(data: JSON, eater: String) -> [Menu]{
        var menus: [Menu] = []
        for (key: String, subJson: JSON) in data {
            menus.append(createMenu(subJson, eater: eater))
        }
        return menus
    }
    
    func createBookings(data: JSON) -> [String] {
        var bookings: [String] = []
        for (key: String, subJson: JSON) in data {
            bookings.append(subJson["eater"].stringValue)
        }
        return bookings
    
    }
    
    func createMenu(data: JSON, eater: String) -> Menu {
        var id  = data["menu"]["id"].stringValue
        var date = data["menu"]["date"].stringValue
        var slots = data["menu"]["slots"].stringValue
        var countGiven = data["menu"]["count_given"].stringValue
        var title = data["dish"]["title"].stringValue
        var details = data["dish"]["details"].stringValue
        var vegetarian =  data["dish"]["vegetarian"].boolValue
        var bookings = createBookings(data["bookings"])
        return Menu(id: id, date: date, slots: slots, countGiven: countGiven, title: title, details: details, vegetarian: vegetarian, eater: eater, bookings: bookings)
    }
    
    class Menu {
        let dateFormatter = NSDateFormatter()
        var title: String
        var details: String
        var vegetarian: Bool
        var id: String
        var slots: String
        var countGiven: String
        var date: String
        var eater: String
        var bookings : [String]
        
        init(id: String, date: String, slots: String, countGiven: String, title: String, details: String, vegetarian: Bool, eater: String, bookings: [String]) {
            self.id = id
            self.date = date
            self.slots = slots
            self.countGiven = countGiven
            self.title = title
            self.details = details
            self.vegetarian = vegetarian
            self.eater = eater
            self.bookings = bookings
        }
        
        func isInTime() -> Bool{
            dateFormatter.dateFormat = "MMMM dd, yyyy hh:mm:ss"
            dateFormatter.timeZone = NSTimeZone(name: "GMT + 1")
            var d1: NSDate = dateFormatter.dateFromString(date)!
        
            dateFormatter.dateFormat = "dd.MM.yyyy"
            var d2: String = dateFormatter.stringFromDate(NSDate()) + " 12:00:00"
            dateFormatter.dateFormat = "dd.MM.yy hh:mm:ss"
            var d3: NSDate = dateFormatter.dateFromString(d2)!
            return d1.timeIntervalSinceDate(d3) > 0
        }
        
        func allreadybooked() {
            contains(bookings, id)
        }
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        // 1
        var stornoAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Stornieren" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 2
            let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .ActionSheet)
            
            let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(cancelAction)
            
            
            self.presentViewController(shareMenu, animated: true, completion: nil)
        })
        // 3
        var anfrageAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Anfragen" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 4
            let rateMenu = UIAlertController(title: nil, message: "Rate this App", preferredStyle: .ActionSheet)
            
            let appRateAction = UIAlertAction(title: "Anfrage", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            rateMenu.addAction(appRateAction)
            rateMenu.addAction(cancelAction)
            
            
            self.presentViewController(rateMenu, animated: true, completion: nil)
        })
        // 5

        return [stornoAction,anfrageAction]
    }
}