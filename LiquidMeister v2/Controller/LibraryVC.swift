//
//  LibraryVC.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/26/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class LibraryVC: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // MARK: - Layout variables
    let lmTitleBar = LMTitleBar()
    
    let libraryTable: UITableView = {
        let tableView = UITableView()
        tableView.register(LibraryCell.self, forCellReuseIdentifier: "libraryCell")
        return tableView
    }()
    
    // MARK: - Data variables
    var dataType: DataType?
    var isSelecting = false
    var newFlavorDelegate: NewFlavorDelegate?
    var selectedCustomerDelegate: SelectedCustomerDelegate?
    var selectedItemDelegate: SelectedItemDelegate?
    var selectedRecipeDelegate: SelectedRecipeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beginConnectionTest()
        layoutView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DataManager.instance.delegate = self
        lmTitleBar.delegate = self
        DataManager.instance.fetchUserData { (_) in
            self.libraryTable.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EditVC {
            destination.transitioningDelegate = transitioningDelegate
            destination.modalPresentationStyle = .custom
            
            destination.dataType = dataType
            if let customer = sender as? Customer {
                destination.customerToEdit = customer
            } else if let inventoryItem = sender as? InventoryItem {
                destination.inventoryItemToEdit = inventoryItem
            } else if let item = sender as? Item {
                destination.itemToEdit = item
            } else if let recipe = sender as? PersonalRecipe {
                destination.recipeToEdit = recipe
            }
        }
    }
    
    func layoutView() {
        view.backgroundColor = Color.primaryBlue.color
        
        libraryTable.backgroundColor = .clear
        libraryTable.dataSource = self
        libraryTable.delegate = self
        libraryTable.rowHeight = UITableViewAutomaticDimension
        libraryTable.tableFooterView = UIView()
        libraryTable.separatorColor = Color.white.color
        libraryTable.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        lmTitleBar.anchor(to: view,
                          top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor)
        
        libraryTable.anchor(to: view,
                            top: lmTitleBar.bottomAnchor,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            bottom: view.safeAreaLayoutGuide.bottomAnchor,
                            padding: .init(top: 10, left: 10, bottom: 0, right: 10))
    }
}

//----------------------------------------------------
// MARK: - Table view data source and delegate methods
//----------------------------------------------------
extension LibraryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataType! {
        case .customer: return DataManager.instance.customers.count
        case .inventory: return DataManager.instance.inventory.count
        case .item: return DataManager.instance.items.count
        case .recipe: return DataManager.instance.recipes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "libraryCell") as! LibraryCell
        cell.dataType = dataType
        switch dataType! {
        case .customer: cell.customerToDisplay = DataManager.instance.customers[indexPath.row]
        case .inventory: cell.inventoryItemToDisplay = DataManager.instance.inventory[indexPath.row]
        case .item: cell.itemToDisplay = DataManager.instance.items[indexPath.row]
        case .recipe: cell.recipeToDisplay = DataManager.instance.recipes[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelecting {
            switch dataType! {
            case .customer: selectedCustomerDelegate?.recieve(DataManager.instance.customers[indexPath.row])
            case .inventory: newFlavorDelegate?.receive(DataManager.instance.inventory[indexPath.row])
            case .item: selectedItemDelegate?.recieve(DataManager.instance.items[indexPath.row])
            case .recipe: selectedRecipeDelegate?.receive(DataManager.instance.recipes[indexPath.row])
            }
            dismiss(animated: true, completion: nil)
        } else {
            switch dataType! {
            case .customer: performSegue(withIdentifier: SegueID.showEdit.rawValue, sender: DataManager.instance.customers[indexPath.row])
            case .inventory: performSegue(withIdentifier: SegueID.showEdit.rawValue, sender: DataManager.instance.inventory[indexPath.row])
            case .item: performSegue(withIdentifier: SegueID.showEdit.rawValue, sender: DataManager.instance.items[indexPath.row])
            case .recipe: performSegue(withIdentifier: SegueID.showEdit.rawValue, sender: DataManager.instance.recipes[indexPath.row])
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath) as! LibraryCell
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, handler) in
            switch self.dataType! {
            case .customer:
                let customerToDelete = DataManager.instance.customers[indexPath.row]
                DataManager.instance.removeFirebaseCustomer(customerToDelete)
            case .inventory:
                let inventoryItemToDelete = DataManager.instance.inventory[indexPath.row]
                let affectedRecipes = inventoryItemToDelete.checkForAffectedRecipes()
                if affectedRecipes.count == 0 {
                    DataManager.instance.removeFirebaseInventoryItem(inventoryItemToDelete)
                } else {
                    DataManager.instance.inventoryItemToDelete = inventoryItemToDelete
                    DataManager.instance.affectedRecipes = affectedRecipes
                    self.showAlert(.affectedRecipes)
                }
            case .item:
                let itemToDelete = DataManager.instance.items[indexPath.row]
                DataManager.instance.removeFirebaseItem(itemToDelete)
            case .recipe:
                let personalRecipeToDelete = DataManager.instance.recipes[indexPath.row]
                DataManager.instance.removeFirebasePersonalRecipe(personalRecipeToDelete)
            }
            
            DataManager.instance.fetchUserData({ (finished) in
                tableView.reloadData()
            })
        }
        delete.image = #imageLiteral(resourceName: "delete")
        
        if let inventoryItem = cell.inventoryItemToDisplay {
            if inventoryItem.name == "Nicotine" || inventoryItem.name == "Propylene Glycol" || inventoryItem.name == "Vegetable Glycerin" {
                return UISwipeActionsConfiguration.init(actions: [])
            } else {
                return UISwipeActionsConfiguration.init(actions: [delete])
            }
        } else {
            return UISwipeActionsConfiguration.init(actions: [delete])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if dataType! == .customer {
            return 62
        }
        
        return UITableViewAutomaticDimension
    }
}
