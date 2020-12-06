//
//  RecipeCell.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/28/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class RecipeCell: UITableViewCell {
    let percentageField: LMTextField = {
        let field = LMTextField(type: .percent)
        return field
    }()
    
    var delegate: UIViewController!
    var ingredientToDisplay: Ingredient?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(delegate: UIViewController, ingredient: Ingredient?) {
        self.init(style: .default, reuseIdentifier: "flavorCell")
        self.delegate = delegate
        self.ingredientToDisplay = ingredient
        self.backgroundColor = .clear
        
        guard let ingredientToDisplay = ingredientToDisplay else {
            layoutAddCell()
            return
        }
        
        layoutForIngredient(ingredient: ingredientToDisplay)
    }
    
    func layoutForIngredient(ingredient: Ingredient) {
        clearCell()
        
        let fieldWidth = (UIScreen.main.bounds.width - 25) / 2
        
        let flavorField: LMTextField = {
            let field = LMTextField(type: .ingredient)
            field.isUserInteractionEnabled = false
            field.text = ingredient.item.name
            return field
        }()
        
        flavorField.delegate = delegate
        flavorField.anchor(to: self,
                           top: self.topAnchor,
                           leading: self.leadingAnchor,
                           bottom: self.bottomAnchor,
                           padding: .init(top: 5, left: 5, bottom: 5, right: 0),
                           size: .init(width: fieldWidth, height: 0))
        
        percentageField.delegate = delegate
        percentageField.text = ingredient.percent?.percentString
        percentageField.anchor(to: self,
                               top: self.topAnchor,
                               leading: flavorField.trailingAnchor,
                               trailing: self.trailingAnchor,
                               bottom: self.bottomAnchor,
                               padding: .init(top: 10, left: 5, bottom: 5, right: 5))
    }
    
    private func layoutAddCell() {
        clearCell()
        
        let addButton = LMButton(type: .addFlavor)
        
        addButton.delegate = delegate
        addButton.anchor(to: self,
                         top: self.topAnchor,
                         leading: self.leadingAnchor,
                         trailing: self.trailingAnchor,
                         bottom: self.bottomAnchor,
                         padding: .init(top: 5, left: 5, bottom: 5, right: 5),
                         size: .init(width: 0, height: 40))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RecipeCell: UITextFieldDelegate {
    
}
