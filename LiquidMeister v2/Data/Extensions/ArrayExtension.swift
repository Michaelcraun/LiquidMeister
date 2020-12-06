//
//  ArrayExtension.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

extension Array where Array == [Customer] {
    func sortByName() -> [Customer] {
        return self.sorted { (customer1, customer2) -> Bool in
            if customer1.name <= customer2.name {
                return customer1.name <= customer2.name
            } else {
                return customer1.name <= customer2.name
            }
        }
    }
}

extension Array where Array == [Ingredient] {
    func contains(_ item: Ingredient) -> Bool {
        var containsItem = false
        for ingredient in self {
            if ingredient == item {
                containsItem = true
                break
            }
        }
        return containsItem
    }
    
    func indexWithName(_ name: String) -> Int? {
        for i in 0..<self.count {
            if self[i].item.name == name {
                return i
            }
        }
        return nil
    }
    
    var debugDescription: String {
        var description = ""
        if self.count > 0 { description = "\(self[0].item.name): percent: \(self[0].percent ?? 0.0)%, \(self[0].amount ?? 0.0)mL" }
        for i in 1..<self.count {
            description += ", \(self[i].item.name): percent: \(self[i].percent ?? 0.0)%, \(self[i].amount ?? 0.0)mL"
        }
        return description
    }
}

extension Array where Array == [InventoryItem] {
    func findItemWithName(_ name: String) -> InventoryItem? {
        for item in self {
            if item.name == name {
                return item
            }
        }
        return nil
    }
    
    func itemWithID(_ id: String) -> InventoryItem? {
        for item in self {
            if let itemID = item.id {
                if itemID == id {
                    return item
                }
            }
        }
        return nil
    }
    
    func sortByName() -> [InventoryItem] {
        return self.sorted { (item1, item2) -> Bool in
            if item1.name <= item2.name {
                return item1.name <= item2.name
            } else {
                return item1.name <= item2.name
            }
        }
    }
    
    func sortByStockAmount() -> [InventoryItem] {
        return self.sorted { (item1, item2) -> Bool in
            if item1.stock <= item2.stock {
                return item1.stock <= item2.stock
            } else {
                return item1.stock <= item2.stock
            }
        }
    }
    
    func getNeedsOrdered() -> [InventoryItem] {
        var inventoryToOrder = [InventoryItem]()
        for item in self {
            if item.stock <= item.orderAt ?? 7.5 {
                inventoryToOrder.append(item)
            }
        }
        return inventoryToOrder
    }
    
    var list: String? {
        var _list = ""
        guard let lastItem = self.last else { return nil }
        if self.count == 1 {
            _list = self[0].name
        } else {
            for item in self {
                if item == lastItem {
                    _list += ", and \(item.name)"
                } else {
                    if _list == "" {
                        _list += item.name
                    } else {
                        _list += ", \(item.name)"
                    }
                }
            }
        }
        
        return _list
    }
}

extension Array where Array == [Item] {
    func sortByName() -> [Item] {
        return self.sorted { (item1, item2) -> Bool in
            if item1.name <= item2.name {
                return item1.name <= item2.name
            } else {
                return item1.name <= item2.name
            }
        }
    }
    
    func sortByPrice() -> [Item] {
        return self.sorted { (item1, item2) -> Bool in
            if item1.price ?? 0.0 <= item2.price ?? 0.0 {
                return item1.price ?? 0.0 <= item2.price ?? 0.0
            } else {
                return item1.price ?? 0.0 <= item2.price ?? 0.0
            }
        }
    }
    
    func sortBySize() -> [Item] {
        return self.sorted { (item1, item2) -> Bool in
            if item1.size <= item2.size {
                return item1.size <= item2.size
            } else {
                return item1.size <= item2.size
            }
        }
    }
}

extension Array where Array == [PersonalRecipe] {
    func sortByFavorites() -> [PersonalRecipe] {
        var favoriteRecipes = [PersonalRecipe]()
        var otherRecipes = [PersonalRecipe]()
        
        for recipe in self {
            if recipe.favorite {
                favoriteRecipes.append(recipe)
            } else {
                otherRecipes.append(recipe)
            }
        }
        
        favoriteRecipes = favoriteRecipes.sortByName()
        otherRecipes = otherRecipes.sortByName()
        
        for recipe in otherRecipes {
            favoriteRecipes.append(recipe)
        }
        
        return favoriteRecipes
    }
    
    func sortByName() -> [PersonalRecipe] {
        return self.sorted { (recipe1, recipe2) -> Bool in
            if recipe1.name <= recipe2.name {
                return recipe1.name <= recipe2.name
            } else {
                return recipe1.name <= recipe2.name
            }
        }
    }
    
    func sortByNumberOfIngredients() -> [PersonalRecipe] {
        return self.sorted { (recipe1, recipe2) -> Bool in
            if recipe1.ingredients.count <= recipe2.ingredients.count {
                return recipe1.ingredients.count <= recipe2.ingredients.count
            } else {
                return recipe1.ingredients.count <= recipe2.ingredients.count
            }
        }
    }
}
