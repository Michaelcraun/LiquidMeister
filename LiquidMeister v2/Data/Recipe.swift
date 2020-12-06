//
//  Recipe.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

class PersonalRecipe {
    var favorite: Bool
    var id: String?
    var name: String
    var notes: String?
    var ingredients: [Ingredient]
    
    init(id: String? = nil, favorite: Bool, name: String, notes: String? = nil, ingredients: [Ingredient]) {
        self.id = id
        self.favorite = favorite
        self.name = name
        self.notes = notes
        self.ingredients = ingredients
    }
    
    func dictionary() -> [String : Any] {
        let id = self.id ?? NSUUID().uuidString
        var ingredientsDict = [[String : Any]]()
        var info: [String : Any] = [FIRKey.UserKey.RecipeKey.favorite.rawValue : favorite,
                                    FIRKey.UserKey.RecipeKey.id.rawValue : id,
                                    FIRKey.UserKey.RecipeKey.name.rawValue : name]
        
        for ingredient in ingredients {
            let inventoryItemID = ingredient.item.id!
            let dictionary = [inventoryItemID : ingredient.percent ?? 0.0]
            ingredientsDict.append(dictionary)
        }
        
        if let notes = notes { info[FIRKey.UserKey.RecipeKey.notes.rawValue] = notes }
        info[FIRKey.UserKey.RecipeKey.ingredients.rawValue] = ingredientsDict
        let dictionary = [id : info]
        return dictionary
    }
    
    func checkForExisting() -> PersonalRecipe? {
        for recipe in DataManager.instance.recipes {
            if recipe.name == self.name {
                return recipe
            }
            
            if recipe.ingredients == self.ingredients {
                return recipe
            }
        }
        return nil
    }
}

class SharedRecipe {
    var id: String?
    var username: String
    var name: String
    var ingredients: [[String : Any]]
    var rating: Double
    
    init(id: String? = nil, username: String, name: String, ingredients: [[String : Any]], rating: Double) {
        self.id = id
        self.username = username
        self.name = name
        self.ingredients = ingredients
        self.rating = rating
    }
}

protocol NewFlavorDelegate: class {
    func receive(_ inventoryItem: InventoryItem)
}

protocol SelectedCustomerDelegate: class {
    func recieve(_ customer: Customer)
}

protocol SelectedItemDelegate: class {
    func recieve(_ item: Item)
}

protocol SelectedRecipeDelegate: class {
    func receive(_ recipe: PersonalRecipe)
}
