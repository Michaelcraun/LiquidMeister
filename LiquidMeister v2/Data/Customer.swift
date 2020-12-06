//
//  Customer.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

class Customer {
    var id: String?
    
    // Information
    var email: String?
    var lastBottle: String?
    var name: String
    var notes: String?
    
    // Preferences
    var nicPercentage: Double?
    var pgPercentage: Double?
    var vgPercentage: Double?
    
    init(id: String? = nil,
         email: String? = nil,
         lastBottle: String? = nil,
         name: String,
         notes: String? = nil,
         nicotinePercentage: Double? = nil,
         pgPercentage: Double? = nil,
         vgPercentage: Double? = nil) {
        if let id = id { self.id = id }
        self.email = email
        self.lastBottle = lastBottle
        self.name = name
        self.notes = notes
        self.nicPercentage = nicotinePercentage
        self.pgPercentage = pgPercentage
        self.vgPercentage = vgPercentage
    }
    
    func dictionary() -> [String : Any] {
        let id = self.id ?? NSUUID().uuidString
        var customerInfo: [String : Any] = [FIRKey.UserKey.CustomerKey.name.rawValue : name,
                                            FIRKey.UserKey.CustomerKey.id.rawValue : id]
        if let email = email { customerInfo[FIRKey.UserKey.CustomerKey.email.rawValue] = email }
        if let lastBottle = lastBottle { customerInfo[FIRKey.UserKey.CustomerKey.lastBottle.rawValue] = lastBottle }
        if let notes = notes { customerInfo[FIRKey.UserKey.CustomerKey.notes.rawValue] = notes }
        if let nicotine = nicPercentage { customerInfo[FIRKey.UserKey.CustomerKey.nicotine.rawValue] = nicotine }
        if let pg = pgPercentage { customerInfo[FIRKey.UserKey.CustomerKey.pg.rawValue] = pg }
        if let vg = vgPercentage { customerInfo[FIRKey.UserKey.CustomerKey.vg.rawValue] = vg }
        
        let customerDict = [id : customerInfo]
        return customerDict
    }
    
    func checkForExisting() -> Customer? {
        for customer in DataManager.instance.customers {
            if customer.name == self.name || customer.email == self.email {
                return customer
            }
        }
        return nil
    }
}
