//
//  DictionaryExtension.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func customer() -> Customer {
        let id = self[FIRKey.UserKey.CustomerKey.id.rawValue] as? String
        let email = self[FIRKey.UserKey.CustomerKey.email.rawValue] as? String
        let name = self[FIRKey.UserKey.CustomerKey.name.rawValue] as? String ?? "No name listed"
        let notes = self[FIRKey.UserKey.CustomerKey.notes.rawValue] as? String
        let nicPercentage = self[FIRKey.UserKey.CustomerKey.nicotine.rawValue] as? Double
        let pgPercentage = self[FIRKey.UserKey.CustomerKey.pg.rawValue] as? Double
        let vgPercentage = self[FIRKey.UserKey.CustomerKey.vg.rawValue] as? Double
        
        let customer = Customer(id: id,
                                email: email,
                                name: name,
                                notes: notes,
                                nicotinePercentage: nicPercentage,
                                pgPercentage: pgPercentage,
                                vgPercentage: vgPercentage)
        
        return customer
    }
    
    func inventoryItem() -> InventoryItem {
        let id = self[FIRKey.UserKey.InventoryKey.id.rawValue] as? String
        let name = self[FIRKey.UserKey.InventoryKey.name.rawValue] as? String ?? "No name listed"
        let manufacturer = self[FIRKey.UserKey.InventoryKey.manufacturer.rawValue] as? String ?? "No manufacturer listed"
        let orderAt = self[FIRKey.UserKey.InventoryKey.orderAt.rawValue] as? Double
        let stock = self[FIRKey.UserKey.InventoryKey.stock.rawValue] as? Double ?? 0.0
        let pgPercentage = self[FIRKey.UserKey.InventoryKey.pg.rawValue] as? Double ?? 100.0
        let vgPercentage = self[FIRKey.UserKey.InventoryKey.vg.rawValue] as? Double ?? 0.0
        
        let inventoryItem = InventoryItem(id: id,
                                          name: name,
                                          manufacturer: manufacturer,
                                          orderAt: orderAt,
                                          stock: stock,
                                          pgPercentage: pgPercentage,
                                          vgPercentage: vgPercentage)
        
        return inventoryItem
    }
    
    func item() -> Item {
        let id = self[FIRKey.UserKey.ItemKey.id.rawValue] as? String
        let name = self[FIRKey.UserKey.ItemKey.name.rawValue] as? String ?? "No name listed"
        let price = self[FIRKey.UserKey.ItemKey.price.rawValue] as? Double ?? 0.0
        let size = self[FIRKey.UserKey.ItemKey.size.rawValue] as? Double ?? 30.0
        
        let item = Item(id: id,
                        name: name,
                        price: price,
                        size: size)
        
        return item
    }
    
    func personalRecipe() -> PersonalRecipe {
        let id = self[FIRKey.UserKey.RecipeKey.id.rawValue] as? String
        let favorite = self[FIRKey.UserKey.RecipeKey.favorite.rawValue] as? Bool ?? false
        let name = self[FIRKey.UserKey.RecipeKey.name.rawValue] as? String ?? "No name listed"
        let notes = self[FIRKey.UserKey.RecipeKey.notes.rawValue] as? String ?? ""
        let ingredients = self[FIRKey.UserKey.RecipeKey.ingredients.rawValue] as? [[String : Any]] ?? [[ : ]]
        
        let recipe = PersonalRecipe(id: id,
                                    favorite: favorite,
                                    name: name,
                                    notes: notes,
                                    ingredients: [])
        
        for ingredient in ingredients {
            if let itemID = ingredient.keys.first {
                if let item = DataManager.instance.inventory.itemWithID(itemID) {
                    let percentage = ingredient.values.first! as? Double
                    let ingredient = Ingredient(item: item, percent: percentage, amount: nil)
                    recipe.ingredients.append(ingredient)
                }
            }
        }
        
        return recipe
    }
    
    func sharedRecipe() -> SharedRecipe {
        let id = self[FIRKey.UserKey.RecipeKey.id.rawValue] as? String
        let username = self[FIRKey.UserKey.RecipeKey.username.rawValue] as? String ?? "No username listed"
        let name = self[FIRKey.UserKey.RecipeKey.name.rawValue] as? String ?? "No name listed"
        let ingredients = self[FIRKey.UserKey.RecipeKey.ingredients.rawValue] as? [[String : Any]] ?? [[ : ]]
        let rating = self[FIRKey.UserKey.RecipeKey.rating.rawValue] as? Double ?? 0.0
        
        let recipe = SharedRecipe(id: id,
                                  username: username,
                                  name: name,
                                  ingredients: ingredients,
                                  rating: rating)
        
        return recipe
    }
}
