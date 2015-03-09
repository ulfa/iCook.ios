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
        println("...\(menus.count)")
        return menus.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(bookingCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.detailTextLabel?.text = "tsdtas"
        println("2... \(self.menus[indexPath.row].eater)")
//        var text = UITextView(frame:CGRectMake(0, 0, cell.frame.width, cell.frame.height))
        return cell
    }
    
    
    //UITableViewDelegate
   override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        println(menus[indexPath.row])
        var cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell?
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
                self.menus += self.createMenus(json["menus"], eater: eater)
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
    
    func createMenu(data: JSON, eater: String) -> Menu {
        var id  = data["menu"]["id"].stringValue
        var date = data["menu"]["date"].stringValue
        var slots = data["menu"]["slots"].stringValue
        var countGiven = data["menu"]["count_given"].stringValue
        var title = data["dish"]["title"].stringValue
        var details = data["dish"]["details"].stringValue
        var vegetarian =  data["dish"]["vegetarian"].boolValue
        return Menu(id: id, date: date, slots: slots, countGiven: countGiven, title: title, details: details, vegetarian: vegetarian, eater: eater)
    }
    
    class Menu {
        var title: String
        var details: String
        var vegetarian: Bool
        var id: String
        var slots: String
        var countGiven: String
        var date: String
        var eater: String
        
        init(id: String, date: String, slots: String, countGiven: String, title: String, details: String, vegetarian: Bool, eater: String) {
            self.id = id
            self.date = date
            self.slots = slots
            self.countGiven = countGiven
            self.title = title
            self.details = details
            self.vegetarian = vegetarian
            self.eater = eater
        }
    }
}

