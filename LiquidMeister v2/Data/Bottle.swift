//
//  Bottle.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

extension Ingredient: Equatable {
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.item == rhs.item && lhs.percent == lhs.percent
    }
}

struct Ingredient {
    var item: InventoryItem
    var percent: Double?
    var amount: Double?
}

class Bottle {
    var customer: Customer? {
        didSet {
            if let nicotineIndex = ingredients.indexWithName("Nicotine") {
                ingredients[nicotineIndex].percent = customer?.nicPercentage ?? 6.0
            }
            
            if let pgIndex = ingredients.indexWithName("Propylene Glycol") {
                ingredients[pgIndex].percent = customer?.pgPercentage ?? 30.0
            }
            
            if let vgIndex = ingredients.indexWithName("Vegetable Glycerin") {
                ingredients[vgIndex].percent = customer?.vgPercentage ?? 70.0
            }
            
            calculateContents()
        }
    }
    
    var item: Item? {
        didSet {
            size =  item?.size  ?? 60.0
            price = item?.price ?? 0.0
            calculateContents()
        }
    }
    
    var recipe: PersonalRecipe? {
        didSet {
            var baseIngredients = fetchBaseIngredients()
            for ingredient in (recipe?.ingredients)! { baseIngredients.append(ingredient) }
            ingredients = baseIngredients
            calculateContents()
        }
    }
    
    var ingredients: [Ingredient]
    var pgPercentage: Double
    var vgPercentage: Double
    var size: Double
    var price: Double
    var flavorPG: Double
    var flavorVG: Double
    var nicotinePG: Double
    var nicotineVG: Double
    var overallContent: Double
    var newRecipeName: String
    
    var description: String {
        return "\(size) mL \(recipe?.name ?? "Custom Bottle")"
    }
    
    init() {
        size = 0.0
        customer = nil
        recipe = nil
        ingredients = []
        pgPercentage = 0.0
        vgPercentage = 0.0
        price = 0.0
        flavorPG = 0.0
        flavorVG = 0.0
        nicotinePG = 0.0
        nicotineVG = 0.0
        overallContent = 0.0
        newRecipeName = ""
    }
    
    private func resetAmounts() {
        pgPercentage = 0.0
        vgPercentage = 0.0
        flavorPG = 0.0
        flavorVG = 0.0
        nicotinePG = 0.0
        nicotineVG = 0.0
        overallContent = 0.0
    }
    
    func contentIsValid() -> Bool {
        if ingredients.count <= 3 { return false }
        if size == 0.0 { return false }
        if size != overallContent { return false }
        var ingredientsHavePercents = true
        
        for ingredient in ingredients {
            if ingredient.item.name != "Nicotine" {
                if let amount = ingredient.amount {
                    if amount > ingredient.item.stock {
                        ingredientsHavePercents = false
                        DataManager.instance.missingIngredient = ingredient.item
                        DataManager.instance.delegate.showAlert(.notEnoughIngredient)
                    }
                }
                
                if ingredient.percent == nil {
                    ingredientsHavePercents = false
                    break
                }
            }
        }
        return ingredientsHavePercents
    }
    
    func calculateContents() {
        resetAmounts()
        var _overallContent = 0.0
        var _ingredients = ingredients
        
        guard let nicotineIndex = _ingredients.indexWithName("Nicotine") else { return }
        var nicotine = _ingredients[nicotineIndex]
        _ingredients.remove(at: nicotineIndex)
        
        guard let pgIndex = _ingredients.indexWithName("Propylene Glycol") else { return }
        var pg = _ingredients[pgIndex]
        _ingredients.remove(at: pgIndex)
        
        guard let vgIndex = _ingredients.indexWithName("Vegetable Glycerin") else { return }
        var vg = _ingredients[vgIndex]
        _ingredients.remove(at: vgIndex)
        
        let flavors = calculateFlavorContent(_ingredients)
        nicotine.amount = calculateNicotineContent(nicotine)
        pg.amount = calculatePropyleneGlycolContent(pg)
        vg.amount = calculateVegetableGlycerinContent(vg)
        
        _ingredients = [nicotine]
        for flavor in flavors { _ingredients.append(flavor) }
        _ingredients.append(pg)
        _ingredients.append(vg)
        
        for ingredient in _ingredients {
            _overallContent += ingredient.amount ?? 0.0
        }
        
        ingredients = _ingredients
        overallContent = _overallContent
    }
    
    func reduceFromInventory() {
        for ingredient in ingredients {
            ingredient.item.stock -= ingredient.amount!
            DataManager.instance.updateFirebaseInventoryItem(ingredient.item)
        }
    }
    
    func createRecipe() {
        var recipeIngredients = ingredients
        if let nicotineIndex = recipeIngredients.indexWithName("Nicotine") { recipeIngredients.remove(at: nicotineIndex) }
        if let pgIndex = recipeIngredients.indexWithName("Propylene Glycol") { recipeIngredients.remove(at: pgIndex) }
        if let vgIndex = recipeIngredients.indexWithName("Vegetable Glycerin") { recipeIngredients.remove(at: vgIndex) }
        
        let newRecipe = PersonalRecipe(favorite: false, name: newRecipeName, ingredients: recipeIngredients)
        if let _ = newRecipe.checkForExisting() {
            DataManager.instance.delegate.showAlert(.recipeExists)
        } else {
            DataManager.instance.updateFirebasePersonalRecipe(newRecipe)
        }
    }
    
    func fetchBaseIngredients() -> [Ingredient] {
        var baseIngredients = [Ingredient]()
        
        if let nicotineItem = DataManager.instance.inventory.findItemWithName("Nicotine") {
            let nicotine = Ingredient(item: nicotineItem, percent: customer?.nicPercentage, amount: nil)
            baseIngredients.append(nicotine)
        }
        
        if let propyleneGlycolItem = DataManager.instance.inventory.findItemWithName("Propylene Glycol") {
            let propyleneGlycol = Ingredient(item: propyleneGlycolItem, percent: customer?.pgPercentage, amount: nil)
            baseIngredients.append(propyleneGlycol)
        }
        
        if let vegetableGlycerinItem = DataManager.instance.inventory.findItemWithName("Vegetable Glycerin") {
            let vegetableGlycerin = Ingredient(item: vegetableGlycerinItem, percent: customer?.vgPercentage, amount: nil)
            baseIngredients.append(vegetableGlycerin)
        }
        
        return baseIngredients
    }
    
    func removeIngredient(at row: Int) {
        ingredients.remove(at: row)
        calculateContents()
        
        if let homeVC = DataManager.instance.delegate as? HomeVC {
            homeVC.ingredientsTable.reloadData()
            
            if recipe != nil {
                if ingredients.count == 3 {
                    recipe = nil
                    homeVC.recipeField.text = ""
                } else {
                    recipe!.name = "Custom \(recipe!.name)"
                    homeVC.recipeField.text = recipe!.name
                }
            }
        }
    }
    
    private func calculateNicotineContent(_ nicotine: Ingredient) -> Double {
        if let percent = nicotine.percent {
            let amount = size * percent * 0.01
            nicotinePG = amount * nicotine.item.pgPercentage * 0.01
            nicotineVG = amount * nicotine.item.vgPercentage * 0.01
            return amount
        }
        return 0.0
    }
    
    private func calculateFlavorContent(_ flavors: [Ingredient]) -> [Ingredient] {
        var _flavors = [Ingredient]()
        for flavor in flavors {
            var _flavor = flavor
            if let percent = flavor.percent {
                let amount = size * percent * 0.01
                let pgAmount = amount * flavor.item.pgPercentage * 0.01
                let vgAmount = amount * flavor.item.vgPercentage * 0.01
                
                flavorPG += pgAmount
                flavorVG += vgAmount
                _flavor.amount = amount
                _flavors.append(_flavor)
            } else {
                _flavors.append(_flavor)
            }
        }
        return _flavors
    }
    
    private func calculatePropyleneGlycolContent(_ pg: Ingredient) -> Double {
        if let percent = pg.percent {
            let amount = size * percent * 0.01 - nicotinePG - flavorPG
            return amount
        }
        return 0.0
    }
    
    private func calculateVegetableGlycerinContent(_ vg: Ingredient) -> Double {
        if let percent = vg.percent {
            let amount = size * percent * 0.01 - nicotineVG - flavorVG
            return amount
        }
        return 0.0
    }
}
