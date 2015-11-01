//
//  Menu.swift
//  iCook.ios
//
//  Created by Ulf Angermann on 17/03/15.
//  Copyright (c) 2015 Ulf Angermann. All rights reserved.
//

import Foundation

class Menu {
    var dateFormatter = NSDateFormatter()
    var title: String
    var details: String
    var vegetarian: Bool
    var id: String
    var slots: String
    var countGiven: String
    let date: String
    var eater: String
    var bookings : [String]
    var eaterNames : String
    var requesters :[String]
    
    init(id: String, date: String, slots: String, countGiven: String, title: String, details: String, vegetarian: Bool, eater: String, bookings: [String], eaterNames: String, requesters: [String]) {
        self.id = id
        self.date = date
        self.slots = slots
        self.countGiven = countGiven
        self.title = title
        self.details = details
        self.vegetarian = vegetarian
        self.eater = eater
        self.bookings = bookings
        self.eaterNames = eaterNames
        self.requesters = requesters
    }
    
    func isInTime() -> Bool {
        dateFormatter.dateFormat = "MMMM dd, yyyy hh:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d1: NSDate = dateFormatter.dateFromString(date)!
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let d2: String = dateFormatter.stringFromDate(NSDate()) + " 12:00:00"
        dateFormatter.dateFormat = "dd.MM.yy hh:mm:ss"
        let d3: NSDate = dateFormatter.dateFromString(d2)!
        return d1.timeIntervalSinceDate(d3) > 0
    }
    
    func convertDate() -> String {
        let dateFormatter1 = NSDateFormatter()
        dateFormatter1.dateFormat = "MMMM dd, yyyy hh:mm:ss"
        dateFormatter1.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d1 = dateFormatter1.dateFromString(date)
        
        let dateFormatter2 = NSDateFormatter()
        dateFormatter2.locale = NSLocale(localeIdentifier: "de_DE_POSIX")
        dateFormatter2.dateFormat = "dd.MM.yyyy (EEEE)"
        return dateFormatter2.stringFromDate(d1!)
    }
    
    
    func allreadybooked() -> Bool{
        return bookings.contains(eater)
    }
    
    func getSlotCount() -> Int {
        return Int(slots)!
    }
    
    func isRequester() -> Bool {
        return requesters.contains(eater)
    }
    
}