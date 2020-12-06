//
//  Flavor.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

class InventoryItem: Equatable {
    static func == (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var manufacturer: String?
    var name: String
    var orderAt: Double? = 7.5
    var stock: Double
    var pgPercentage: Double = 0.0
    var vgPercentage: Double = 100.0
    
    init(id: String? = nil,
         name: String,
         manufacturer: String? = nil,
         orderAt: Double? = nil,
         stock: Double,
         pgPercentage: Double = 0.0,
         vgPercentage: Double = 100.0) {
        self.id = id
        self.name = name
        self.manufacturer = manufacturer
        self.orderAt = orderAt
        self.stock = stock
        self.pgPercentage = pgPercentage
        self.vgPercentage = vgPercentage
    }
    
    func dictionary() -> [String : Any] {
        let id = self.id ?? NSUUID().uuidString
        var info: [String : Any] = [FIRKey.UserKey.InventoryKey.id.rawValue : id,
                                    FIRKey.UserKey.InventoryKey.name.rawValue : name,
                                    FIRKey.UserKey.InventoryKey.pg.rawValue : pgPercentage,
                                    FIRKey.UserKey.InventoryKey.stock.rawValue : stock,
                                    FIRKey.UserKey.InventoryKey.vg.rawValue : vgPercentage]
        
        if let manufacturer = manufacturer { info[FIRKey.UserKey.InventoryKey.manufacturer.rawValue] = manufacturer }
        if let orderAt = orderAt { info[FIRKey.UserKey.InventoryKey.orderAt.rawValue] = orderAt }
        
        let inventoryDict = [id : info]
        return inventoryDict
    }
    
    func checkForExisting() -> InventoryItem? {
        for item in DataManager.instance.inventory {
            if item.name == self.name && item.manufacturer == self.name {
                return item
            }
        }
        return nil
    }
    
    func checkForAffectedRecipes() -> [PersonalRecipe] {
        var affectedRecipes = [PersonalRecipe]()
        
        for recipe in DataManager.instance.recipes {
            for ingredient in recipe.ingredients {
                if ingredient.item.id == self.id {
                    affectedRecipes.append(recipe)
                }
            }
        }
        
        return affectedRecipes
    }
}
