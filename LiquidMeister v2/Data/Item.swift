//
//  Item.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

class Item {
    var id: String?
    var name: String
    var price: Double?
    var size: Double
    
    init(id: String? = nil, name: String, price: Double? = nil, size: Double) {
        self.id = id
        self.name = name
        self.price = price
        self.size = size
    }
    
    func dictionary() -> [String : Any] {
        let id = self.id ?? NSUUID().uuidString
        var info: [String : Any] = [FIRKey.UserKey.ItemKey.id.rawValue : id,
                                    FIRKey.UserKey.ItemKey.name.rawValue : name,
                                    FIRKey.UserKey.ItemKey.size.rawValue : size]
        
        if let price = price { info[FIRKey.UserKey.ItemKey.price.rawValue] = price }
        
        let dictionary = [id : info]
        return dictionary
    }
    
    func checkForExisting() -> Item? {
        for item in DataManager.instance.items {
            if item.name == self.name {
                return item
            }
        }
        return nil
    }
}
