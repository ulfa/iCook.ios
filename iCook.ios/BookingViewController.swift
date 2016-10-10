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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Do any additional setup after loading the view, typically from a nib.
        //customizeView()
        tableView.delegate = self
        tableView.dataSource = self
        super.refreshControl = UIRefreshControl()
        super.refreshControl?.addTarget(self, action: #selector(BookingViewController.refresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let settings = appDelegate.loadSettings()
        print(settings)
        baseURI = settings[appDelegate.LOCATION]!
        account = appDelegate.createAccount(settings[appDelegate.ACCOUNT]!, passwd: settings[appDelegate.PASSWORD]!)
        initBookings()
    }

    func customizeView() {
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.backgroundColor = UIColor.lightText
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.tabBarController?.tabBar.barTintColor = UIColor.red
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: bookingCellIdentifier, for: indexPath) as! BookingCell
        cell.bookinDate.text = menus[(indexPath as IndexPath).row].convertDate()
        cell.bookingTitle.text = menus[(indexPath as NSIndexPath).row].title
        cell.bookingTitle.font = UIFont(name:"HelveticaNeue-Bold", size: 24)
        
        cell.bookingDetails.text = menus[(indexPath as NSIndexPath).row].details
        cell.bookingDetails.font = UIFont(name:"HelveticaNeue -Bold", size: 18)
    
        if menus[(indexPath as NSIndexPath).row].allreadybooked() {
            cell.bookedImage?.image = iconHaken
        } else if menus[(indexPath as NSIndexPath).row].isRequester() {
            cell.bookedImage?.image = iconAnfrage
        } else {
           cell.bookedImage?.image = nil
        }
        if !menus[(indexPath as NSIndexPath).row].isInTime()  {
            createStruckOut(menus[(indexPath as NSIndexPath).row].details, label: cell.bookingDetails)
            createStruckOut(menus[(indexPath as NSIndexPath).row].title, label: cell.bookingTitle)
        }
        let menu = menus[(indexPath as IndexPath).row]
        cell.bookingFreeMeals.text = menu.slots + " : " + menu.countGiven + " : " + menu.vegieCount
        cell.bookingFreeMeals.font = UIFont(name:"HelveticaNeue-Bold", size: 12)
        cell.bookingFreeMeals.textColor = UIColor.lightGray
        
        return cell
    }
    
    func createStruckOut(_ text: String, label: UILabel)  {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        label.attributedText = attributeString
    }
    
    //UITableViewDelegate
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        _ = tableView.cellForRow(at: indexPath) as! BookingCell?
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func refresh(_ sender:AnyObject) {
        initBookings()
        super.refreshControl?.endRefreshing()
    }
    
    func initBookings() {
        
        let headers = [
            "Authorization": "Basic " + self.account,
            "Accept": "application/json"
        ]
        
        Alamofire.request(baseURI + url, method: .get, headers: headers)
            .responseJSON {response in
                switch response.result {
                    case .success(let data):
                        let json = JSON(data)
                        let eater = json["eater_id"].stringValue
                        self.menus = self.createMenus(json["menus"], eater: eater)
                        self.tableView.reloadData()
                    case .failure(let error):
                        print(response.debugDescription)
                        print("Request failed with error: \(error)")
                }
            }
    }
    
    func createMenus(_ data: JSON, eater: String) -> [Menu]{
        var menus: [Menu] = []
        for (_, subJson) in data {
            menus.append(createMenu(subJson, eater: eater))
        }
        return menus
    }
    
    func createBookings(_ data: JSON) -> [String] {
        var bookings: [String] = []
        for (_, subJson)  in data {
            bookings.append(subJson["eater"].stringValue)
        }
        return bookings
    }

    func createRequesters(_ data: JSON) -> [String] {
        var requesters: [String] = []
        for (_, subJson) in data {
            requesters.append(subJson["requester"].stringValue)
        }
        return requesters
    }
    
    func createVegieCount(_ data: JSON) -> String {
        return data.stringValue
    }


    func createMenu(_ data: JSON, eater: String) -> Menu {
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
        let vegieCount = createVegieCount(data["vegie_count"])
        return Menu(id: id, date: date, slots: slots, countGiven: countGiven, title: title, details: details, vegetarian: vegetarian, eater: eater, bookings: bookings, eaterNames: eaterNames, requesters: requesters, vegieCount: vegieCount)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?  {
        let stornoAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Stornieren" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in

            let parameters = ["eater-id": self.menus[indexPath.row].eater,
                              "menu-id": self.menus[indexPath.row].id
                             ]
            self.sendRequest(self.baseURI + self.stornoUrl, parameters: parameters as [String : AnyObject])
        })

        let anfrageAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Anfragen" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in

            let parameters = ["eater-id": self.menus[indexPath.row].eater,
                              "menu-id": self.menus[indexPath.row].id
                             ]
            
            self.sendRequest(self.baseURI + self.requestUrl, parameters: parameters as [String : AnyObject])
        })

        let bookingAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Buchen" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            
            let parameters = ["eater-id": self.menus[indexPath.row].eater,
                              "menu-id": self.menus[indexPath.row].id
                             ]
            
            self.sendRequest(self.baseURI + self.bookingUrl, parameters: parameters as [String : AnyObject])
        })
        
        let esserAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Esser" , handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.createAllEaterView(self.menus[indexPath.row].eaterNames)
        })
        esserAction.backgroundColor = UIColor.lightGray
        stornoAction.backgroundColor = UIColor.red
        anfrageAction.backgroundColor = UIColor.red
        bookingAction.backgroundColor = UIColor.blue

        if (self.menus[(indexPath as NSIndexPath).row].allreadybooked() && self.menus[(indexPath as NSIndexPath).row].isInTime()) {
            return [esserAction, stornoAction]
        } else if (Int(self.menus[(indexPath as NSIndexPath).row].countGiven) > 0 && self.menus[(indexPath as NSIndexPath).row].isInTime()) {
            return [esserAction, bookingAction]
        } else if (self.menus[(indexPath as NSIndexPath).row].isInTime()) {
            return [esserAction, anfrageAction]
        }
        return [esserAction]
    }
    
    func sendRequest(_ url: String, parameters: [String: AnyObject]) {
        let headers = [
            "Authorization": "Basic " + self.account,
            "Accept": "application/json"
        ]

        Alamofire.request(url, method: .post, parameters: parameters, headers: headers).response{
            response in
            self.initBookings()
        }
    }
    
    func createAllEaterView(_ eaterNames: String) {
        let alert = UIAlertController(title: "Esser", message: eaterNames, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
