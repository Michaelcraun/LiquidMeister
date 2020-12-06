//
//  IngredientCell.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/26/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit
import TextFieldEffects

class IngredientCell: UITableViewCell {
    let ingredientField = LMTextField(type: .ingredient)
    let percentField = LMTextField(type: .percent)
    let amountField = LMTextField(type: .amount)
    
    var delegate: UIViewController!
    var ingredient: Ingredient?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(delegate: UIViewController, ingredient: Ingredient?) {
        self.init(style: .default, reuseIdentifier: "ingredientCell")
        self.delegate = delegate
        self.ingredient = ingredient
        clearCell()
        
        ingredientField.delegate = delegate
        percentField.delegate = delegate
        amountField.delegate = delegate
        percentField.textField.delegate = self
        
        if let ingredient = ingredient {
            layoutForItem(ingredient)
        } else {
            layoutForAdd()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = .clear
    }
    
    func layoutForItem(_ ingredient: Ingredient) {
        let fieldWidth = (UIScreen.main.bounds.width - 30) / 2
        
        ingredientField.text = ingredient.item.name
        ingredientField.anchor(to: self,
                               top: self.topAnchor,
                               leading: self.leadingAnchor,
                               trailing: self.trailingAnchor,
                               padding: .init(top: 5, left: 0, bottom: 0, right: 0))
        
        percentField.text = ingredient.percent?.percentString
        percentField.anchor(to: self,
                            top: ingredientField.bottomAnchor,
                            leading: self.leadingAnchor,
                            bottom: self.bottomAnchor,
                            padding: .init(top: 5, left: 0, bottom: 5, right: 0),
                            size: .init(width: fieldWidth, height: 0))
        
        amountField.text = ingredient.amount?.amountString
        amountField.anchor(to: self,
                           top: ingredientField.bottomAnchor,
                           leading: percentField.trailingAnchor,
                           trailing: self.trailingAnchor,
                           bottom: self.bottomAnchor,
                           padding: .init(top: 5, left: 10, bottom: 5, right: 0))
    }
    
    func layoutForAdd() {
        let addButton = LMButton(type: .addFlavor)
        addButton.delegate = delegate
        addButton.anchor(to: self,
                         top: self.topAnchor,
                         leading: self.leadingAnchor,
                         trailing: self.trailingAnchor,
                         bottom: self.bottomAnchor,
                         padding: .init(top: 10, left: 0, bottom: 10, right: 0),
                         size: .init(width: 0, height: 40))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//----------------------------
// MARK: - Text field delegate
//----------------------------
extension IngredientCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("IngredientCell is delegate!")
        delegate.view.addTapToDismissKeyboard()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate.view.removeTapToDismissKeyboard()
        if textField == percentField.textField as UITextField {
            guard let flavorIndex = DataManager.instance.bottle.ingredients.indexWithName(ingredientField.text!) else { return }
            guard let text = textField.text, text != "", let percentage = Double(text) else {
                textField.text = ""
                return
            }
            
            DataManager.instance.bottle.ingredients[flavorIndex].percent = percentage
            DataManager.instance.bottle.calculateContents()
            if let homeVC = delegate as? HomeVC {
                homeVC.ingredientsTable.reloadData()
            }
        }
    }
}
