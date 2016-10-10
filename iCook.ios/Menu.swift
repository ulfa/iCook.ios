//
//  Menu.swift
//  iCook.ios
//
//  Created by Ulf Angermann on 17/03/15.
//  Copyright (c) 2015 Ulf Angermann. All rights reserved.
//

import Foundation

class Menu {
    var dateFormatter = DateFormatter()
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
    var vegieCount : String
    
    init(id: String, date: String, slots: String, countGiven: String, title: String, details: String, vegetarian: Bool, eater: String, bookings: [String], eaterNames: String, requesters: [String], vegieCount: String) {
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
        self.vegieCount = vegieCount
    }
    
    func isInTime() -> Bool {
        dateFormatter.dateFormat = "MMMM dd, yyyy hh:mm:ss"
        //dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d1: Date = dateFormatter.date(from: date)!
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let d2: String = dateFormatter.string(from: Date()) + " 12:00:00"
        dateFormatter.dateFormat = "dd.MM.yy hh:mm:ss"
        let d3: Date = dateFormatter.date(from: d2)!
        return d1.timeIntervalSince(d3) > 0
    }
    
    func convertDate() -> String {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MMMM dd, yyyy hh:mm:ss"
        //dateFormatter1.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
        dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
        print(date)
        let d1 = dateFormatter1.date(from: date)
        print(d1)
        let dateFormatter2 = DateFormatter()
        dateFormatter2.locale = Locale(identifier: "de_DE_POSIX")
        dateFormatter2.dateFormat = "dd.MM.yyyy (EEEE)"
        print(date)
        return dateFormatter2.string(from: d1!)
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
