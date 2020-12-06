//
//  HomeVC.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit
import TextFieldEffects

class HomeVC: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.5
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "bgImage")
        return imageView
    }()
    
    let lmTitleBar = LMTitleBar()
    let sizeField = LMTextField(type: .size)
    let customerField = LMTextField(type: .customer)
    let recipeField = LMTextField(type: .recipe)
    let createRecipeButton = LMButton(type: .createRecipe)
    var createButton = LMButton(type: .createBottle)
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    let ingredientsTable: UITableView = {
        let tableView = UITableView()
        tableView.register(IngredientCell.self, forCellReuseIdentifier: "ingredientCell")
        return tableView
    }()
    
    // MARK: - Data variables
    let bottle = Bottle()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beginConnectionTest()
        layoutView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if DataManager.instance.currentUserID == nil {
            DataManager.instance = DataManager()
        }
        
        DataManager.instance.delegate = self
        lmTitleBar.delegate = self
        createRecipeButton.delegate = self
        createButton.delegate = self
        sizeField.delegate = self
        customerField.delegate = self
        recipeField.delegate = self
        ingredientsTable.backgroundColor = .clear
        ingredientsTable.dataSource = self
        ingredientsTable.delegate = self
        ingredientsTable.separatorStyle = .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LibraryVC {
            if let sender = sender as? String {
                slideInTransitioningDelegate.direction = .right
                slideInTransitioningDelegate.disableCompactHeight = false
                destination.transitioningDelegate = slideInTransitioningDelegate
                destination.modalPresentationStyle = .custom
                
                destination.dataType = DataType(rawValue: sender)
                destination.isSelecting = true
                destination.newFlavorDelegate = self
                destination.selectedCustomerDelegate = self
                destination.selectedItemDelegate = self
                destination.selectedRecipeDelegate = self
            }
        } else if let destination = segue.destination as? SettingsVC {
            slideInTransitioningDelegate.direction = .left
            slideInTransitioningDelegate.disableCompactHeight = false
            destination.transitioningDelegate = slideInTransitioningDelegate
            destination.modalPresentationStyle = .custom
        }
    }
    
    private func layoutView() {
        let viewWidth = view.frame.width
        let buttonWidth = (viewWidth - 30) / 2
        view.backgroundColor = Color.primaryBlue.color
        
        backgroundImageView.fillTo(view)
        
        lmTitleBar.anchor(to: view,
                          top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor)
        
        sizeField.anchor(to: view,
                         top: lmTitleBar.bottomAnchor,
                         leading: view.leadingAnchor,
                         padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                         size: .init(width: 100, height: 0))
        
        customerField.anchor(to: view,
                             top: lmTitleBar.bottomAnchor,
                             leading: sizeField.trailingAnchor,
                             trailing: view.trailingAnchor,
                             padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        recipeField.anchor(to: view,
                           top: sizeField.bottomAnchor,
                           leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        createRecipeButton.anchor(to: view,
                                  leading: view.leadingAnchor,
                                  bottom: view.bottomAnchor,
                                  padding: .init(top: 0, left: 10, bottom: 10, right: 0),
                                  size: .init(width: buttonWidth, height: 40))
        
        createButton.anchor(to: view,
                               leading: createRecipeButton.trailingAnchor,
                               trailing: view.trailingAnchor,
                               bottom: view.bottomAnchor,
                               padding: .init(top: 0, left: 10, bottom: 10, right: 10),
                               size: .init(width: 0, height: 40))
        
        ingredientsTable.anchor(to: view,
                                top: recipeField.bottomAnchor,
                                leading: view.leadingAnchor,
                                trailing: view.trailingAnchor,
                                bottom: createRecipeButton.topAnchor,
                                padding: .init(top: 10, left: 10, bottom: 10, right: 10))
    }
}

//--------------------------------------------
// MARK: - Table view data source and delegate
//--------------------------------------------
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.instance.bottle.ingredients.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < DataManager.instance.bottle.ingredients.count {
            let cell = IngredientCell(delegate: self, ingredient: DataManager.instance.bottle.ingredients[indexPath.row])
            return cell
        } else {
            let cell = IngredientCell(delegate: self, ingredient: nil)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == DataManager.instance.bottle.ingredients.count {
            performSegue(withIdentifier: SegueID.addFlavor.rawValue, sender: "inventory")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! IngredientCell
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, handler) in
            DataManager.instance.bottle.removeIngredient(at: indexPath.row)
        }
        delete.image = #imageLiteral(resourceName: "delete")
        
        if cell.ingredient?.item.name == "Propylene Glycol" || cell.ingredient?.item.name == "Vegetable Glycerin" {
            return UISwipeActionsConfiguration.init(actions: [])
        } else {
            return UISwipeActionsConfiguration.init(actions: [delete])
        }
    }
}

extension HomeVC: NewFlavorDelegate {
    func receive(_ inventoryItem: InventoryItem) {
        let ingredient = Ingredient(item: inventoryItem, percent: nil, amount: nil)
        DataManager.instance.bottle.ingredients.append(ingredient)
        DataManager.instance.bottle.calculateContents()
        ingredientsTable.reloadData()
    }
}

extension HomeVC: SelectedCustomerDelegate {
    func recieve(_ customer: Customer) {
        DataManager.instance.bottle.customer = customer
        customerField.text = customer.name
        ingredientsTable.reloadData()
    }
}

extension HomeVC: SelectedItemDelegate {
    func recieve(_ item: Item) {
        DataManager.instance.bottle.item = item
        sizeField.text = item.size.amountString
    }
}

extension HomeVC: SelectedRecipeDelegate {
    func receive(_ recipe: PersonalRecipe) {
        DataManager.instance.bottle.recipe = recipe
        recipeField.text = recipe.name
        ingredientsTable.reloadData()
    }
}
