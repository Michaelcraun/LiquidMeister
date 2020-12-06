//
//  EditVC.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/27/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class EditVC: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // MARK: - Layout variables
    var blurView: UIVisualEffectView?
    let lmTitleBar = LMTitleBar()
    let emailField = LMTextField(type: .email)
    let lastBottleField = LMTextField(type: .lastBottle)
    let manufacturerField = LMTextField(type: .manufacturer)
    let nameField = LMTextField(type: .name)
    let nicotineField = LMTextField(type: .nicotine)
    let orderAtField = LMTextField(type: .orderAt)
    let pgField = LMTextField(type: .pg)
    let priceField = LMTextField(type: .price)
    let sizeField = LMTextField(type: .size)
    let stockField = LMTextField(type: .stock)
    let vgField = LMTextField(type: .vg)
    let saveButton = LMButton(type: .save)
    
    let notesButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(showNotes(_:)), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "notes"), for: .normal)
        return button
    }()
    
    let flavorsTable: UITableView = {
        let tableView = UITableView()
        tableView.register(RecipeCell.self, forCellReuseIdentifier: "flavorCell")
        return tableView
    }()
    
    let notesView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryBlue.color
        view.layer.borderColor = Color.primaryBlack.color.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 10
        return view
    }()
    
    // MARK: - Data variables
    var dataType: DataType?
    var notes: String? 
    var customerToEdit: Customer?
    var inventoryItemToEdit: InventoryItem?
    var itemToEdit: Item?
    var recipeToEdit: PersonalRecipe?
    var recipeIsFavorite = false
    var recipeIngredients = [Ingredient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beginConnectionTest()
        layoutView()
        loadDataIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DataManager.instance.delegate = self
        lmTitleBar.delegate = self
        emailField.delegate = self
        lastBottleField.delegate = self
        manufacturerField.delegate = self
        nameField.delegate = self
        nicotineField.delegate = self
        orderAtField.delegate = self
        pgField.delegate = self
        priceField.delegate = self
        sizeField.delegate = self
        stockField.delegate = self
        vgField.delegate = self
        saveButton.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LibraryVC {
            destination.transitioningDelegate = transitioningDelegate
            destination.dataType = .inventory
            destination.isSelecting = true
            destination.newFlavorDelegate = self
        }
    }
    
    private func layoutView() {
        view.backgroundColor = Color.primaryBlue.color
        
        lmTitleBar.anchor(to: view,
                          top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor)
        
        saveButton.anchor(to: view,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          bottom: view.safeAreaLayoutGuide.bottomAnchor,
                          padding: .init(top: 0, left: 10, bottom: 10, right: 10),
                          size: .init(width: 0, height: 40))
        
        switch dataType! {
        case .customer:     layoutViewForCustomer()
        case .inventory:    layoutViewForInventoryItem()
        case .item:         layoutViewForItem()
        case .recipe:       layoutViewForRecipe()
        }
    }
    
    private func layoutViewForCustomer() {
        let fieldWidth: CGFloat = (UIScreen.main.bounds.width - 40) / 3
        
        nameField.anchor(to: view,
                         top: lmTitleBar.bottomAnchor,
                         leading: view.leadingAnchor,
                         padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                         size: .init(width: UIScreen.main.bounds.width - 66, height: 0))
        
        notesButton.anchor(to: view,
                           top: lmTitleBar.bottomAnchor,
                           trailing: view.trailingAnchor,
                           padding: .init(top: 10, left: 0, bottom: 0, right: 10),
                           size: .init(width: nameField.frame.height, height: nameField.frame.height))
        
        emailField.anchor(to: view,
                          top: nameField.bottomAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        lastBottleField.anchor(to: view,
                               top: emailField.bottomAnchor,
                               leading: view.leadingAnchor,
                               trailing: view.trailingAnchor,
                               padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        nicotineField.anchor(to: view,
                             top: lastBottleField.bottomAnchor,
                             leading: view.leadingAnchor,
                             padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                             size: .init(width: fieldWidth, height: 0))
        
        pgField.anchor(to: view,
                       top: lastBottleField.bottomAnchor,
                       leading: nicotineField.trailingAnchor,
                       padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                       size: .init(width: fieldWidth, height: 0))
        
        vgField.anchor(to: view,
                       top: lastBottleField.bottomAnchor,
                       leading: pgField.trailingAnchor,
                       trailing: view.trailingAnchor,
                       padding: .init(top: 10, left: 10, bottom: 0, right: 10))
    }
    
    private func layoutViewForInventoryItem() {
        let fieldWidth = (UIScreen.main.bounds.width - 30) / 2
        let calculatorView = LMCaclulatorView(delegate: self, textField: stockField, inventoryItem: nil)
        calculatorView.anchor()
        
        nameField.anchor(to: view,
                         top: lmTitleBar.bottomAnchor,
                         leading: view.leadingAnchor,
                         trailing: view.trailingAnchor,
                         padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        manufacturerField.anchor(to: view,
                                 top: nameField.bottomAnchor,
                                 leading: view.leadingAnchor,
                                 trailing: view.trailingAnchor,
                                 padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                                 size: .init(width: 0, height: 0))
        
        stockField.textField.inputView = calculatorView
        stockField.anchor(to: view,
                          top: manufacturerField.bottomAnchor,
                          leading: view.leadingAnchor,
                          padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                          size: .init(width: fieldWidth, height: 0))
        
        orderAtField.anchor(to: view, top: manufacturerField.bottomAnchor,
                            leading: stockField.trailingAnchor,
                            trailing: view.trailingAnchor,
                            padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                            size: .init(width: fieldWidth, height: 0))
        
        pgField.anchor(to: view,
                       top: stockField.bottomAnchor,
                       leading: view.leadingAnchor,
                       padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                       size: .init(width: fieldWidth, height: 0))
        
        vgField.anchor(to: view,
                       top: orderAtField.bottomAnchor,
                       leading: pgField.trailingAnchor,
                       trailing: view.trailingAnchor,
                       padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                       size: .init(width: fieldWidth, height: 0))
    }
    
    private func layoutViewForItem() {
        let fieldWidth = (UIScreen.main.bounds.width - 30) / 2
        
        nameField.anchor(to: view,
                         top: lmTitleBar.bottomAnchor,
                         leading: view.leadingAnchor,
                         trailing: view.trailingAnchor,
                         padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        sizeField.anchor(to: view,
                         top: nameField.bottomAnchor,
                         leading: view.leadingAnchor,
                         padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                         size: .init(width: fieldWidth, height: 0))
        
        priceField.anchor(to: view,
                          top: nameField.bottomAnchor,
                          leading: sizeField.trailingAnchor,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                          size: .init(width: fieldWidth, height: 0))
    }
    
    private func layoutViewForRecipe() {
        flavorsTable.backgroundColor = .clear
        flavorsTable.dataSource = self
        flavorsTable.delegate = self
        flavorsTable.separatorStyle = .none
        
        nameField.anchor(to: view,
                         top: lmTitleBar.bottomAnchor,
                         leading: view.leadingAnchor,
                         padding: .init(top: 10, left: 10, bottom: 0, right: 0),
                         size: .init(width: UIScreen.main.bounds.width - 66, height: 0))
        
        notesButton.anchor(to: view,
                           top: lmTitleBar.bottomAnchor,
                           trailing: view.trailingAnchor,
                           padding: .init(top: 10, left: 0, bottom: 0, right: 10),
                           size: .init(width: nameField.frame.height, height: nameField.frame.height))
        
        flavorsTable.anchor(to: view,
                            top: nameField.bottomAnchor,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            bottom: saveButton.topAnchor,
                            padding: .init(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    // MARK: - Save data
    func saveData() {
        switch dataType! {
        case .customer:     saveCustomer()
        case .inventory:    saveInventoryItem()
        case .item:         saveItem()
        case .recipe:       savePersonalRecipe()
        }
    }
    
    private func saveCustomer() {
        guard let createdCustomer = createCustomerFromForm() else { return }
        guard let customerToEdit = customerToEdit else {
            if let _ = createdCustomer.checkForExisting() {
                showAlert(.existingInventoryItem)
            } else {
                DataManager.instance.updateFirebaseCustomer(createdCustomer)
            }
            return
        }
        createdCustomer.id = customerToEdit.id
        DataManager.instance.updateFirebaseCustomer(createdCustomer)
    }
    
    private func createCustomerFromForm() -> Customer? {
        guard let name = nameField.text, name != "" else {
            showAlert(.missingName)
            return nil
        }
        
        let customer = Customer(name: name)
        if let email = emailField.text, email != "" { customer.email = email }
        if let notes = notes, notes != "" { customer.notes = notes }
        
        if let nicotine = nicotineField.text, nicotine != "" {
            let nicotinePercentage = Double(nicotine.removing(" mL"))
            customer.nicPercentage = nicotinePercentage
        }
        
        if let pg = pgField.text, pg != "" {
            let pgPercentage = Double(pg.removing("%"))
            customer.pgPercentage = pgPercentage
        }
        
        if let vg = vgField.text, vg != "" {
            let vgPercentage = Double(vg.removing("%"))
            customer.vgPercentage = vgPercentage
        }
        
        return customer
    }
    
    private func saveInventoryItem() {
        guard let createdInventoryItem = createInventoryItemFromForm() else { return }
        guard let inventoryItemToEdit = inventoryItemToEdit else {
            if let _ = createdInventoryItem.checkForExisting() {
                showAlert(.existingInventoryItem)
            } else {
                DataManager.instance.updateFirebaseInventoryItem(createdInventoryItem)
            }
            return
        }
        createdInventoryItem.id = inventoryItemToEdit.id
        DataManager.instance.updateFirebaseInventoryItem(createdInventoryItem)
    }
    
    private func createInventoryItemFromForm() -> InventoryItem? {
        guard let name = nameField.text, name != "" else {
            showAlert(.missingName)
            return nil
        }
        
        guard let stock = stockField.text, stock != "", let stockAmount = Double(stock.removing(" mL")) else {
            showAlert(.missingStock)
            return nil
        }
        
        let inventoryItem = InventoryItem(name: name, stock: stockAmount)
        if let manufacturer = manufacturerField.text, manufacturer != "" { inventoryItem.manufacturer = manufacturer }
        if let orderAt = orderAtField.text, orderAt != "", let orderAtAmount = Double(orderAt.removing(" mL")) { inventoryItem.orderAt = orderAtAmount }
        if let pg = pgField.text, pg != "", let pgAmount = Double(pg.removing(" mL")) { inventoryItem.pgPercentage = pgAmount }
        if let vg = vgField.text, vg != "", let vgAmount = Double(vg.removing(" mL")) { inventoryItem.vgPercentage = vgAmount }
        
        return inventoryItem
    }
    
    private func saveItem() {
        guard let createdItem = createItemFromForm() else { return }
        guard let itemToEdit = itemToEdit else {
            if let _ = createdItem.checkForExisting() {
                showAlert(.existingItem)
            } else {
                DataManager.instance.updateFirebaseItem(createdItem)
            }
            return
        }
        createdItem.id = itemToEdit.id
        DataManager.instance.updateFirebaseItem(createdItem)
    }
    
    private func createItemFromForm() -> Item? {
        guard let name = nameField.text, name != "" else {
            showAlert(.missingName)
            return nil
        }
        
        guard let size = sizeField.text, size != "", let sizeAmount = Double(size.removing(" mL")) else {
            showAlert(.missingSize)
            return nil
        }
        
        let item = Item(name: name, size: sizeAmount)
        if let price = priceField.text, price != "", let priceAmount = Double(price.removing("$")) { item.price = priceAmount }
        return item
    }
    
    private func savePersonalRecipe() {
        guard let createdRecipe = createPersonalRecipeFromForm() else { return }
        guard let recipeToEdit = recipeToEdit else {
            // Creating a new recipe
            if let _ = createdRecipe.checkForExisting() {
                showAlert(.existingRecipe)
            } else {
                DataManager.instance.updateFirebasePersonalRecipe(createdRecipe)
            }
            return
        }
        // Updating an existing recipe
        createdRecipe.id = recipeToEdit.id
        DataManager.instance.updateFirebasePersonalRecipe(createdRecipe)
    }
    
    private func createPersonalRecipeFromForm() -> PersonalRecipe? {
        guard let name = nameField.text, name != "" else {
            showAlert(.missingName)
            return nil
        }
        
        if recipeIngredients.count > 0 {
            for i in 0..<recipeIngredients.count {
                guard let cell = flavorsTable.cellForRow(at: IndexPath(row: i, section: 0)) as? RecipeCell else { return nil }
                guard let percentage = cell.percentageField.text, percentage != "", let percentageAmount = Double(percentage.removing("%")) else {
                    showAlert(.percentageError)
                    return nil
                }
                recipeIngredients[i].percent = percentageAmount
            }
        } else {
            showAlert(.missingIngredients)
        }
        
        let personalRecipe = PersonalRecipe(favorite: recipeIsFavorite, name: name, notes: notes, ingredients: recipeIngredients)
        return personalRecipe
    }
    
    // MARK: - Load functions
    private func loadDataIfNeeded() {
        switch dataType! {
        case .customer: 	loadCustomer()
        case .inventory:    loadInventoryItem()
        case .item:         loadItem()
        case .recipe:       loadPersonalRecipe()
        }
    }
    
    private func loadCustomer() {
        guard let customer = customerToEdit else { return }
        nameField.text = customer.name
        if let email = customer.email { emailField.text = email }
        if let lastBottle = customer.lastBottle { emailField.text = lastBottle }
        if let nicPercentage = customer.nicPercentage { nicotineField.text = nicPercentage.percentString }
        if let notes = customer.notes { self.notes = notes }
        if let pgPercentage = customer.pgPercentage { pgField.text = pgPercentage.percentString }
        if let vgPercentage = customer.vgPercentage { vgField.text = vgPercentage.percentString }
    }
    
    private func loadInventoryItem() {
        guard let inventoryItem = inventoryItemToEdit else { return }
        let calculatorView = LMCaclulatorView(delegate: self, textField: stockField, inventoryItem: inventoryItem)
        calculatorView.anchor()
        nameField.text = inventoryItem.name
        pgField.text = inventoryItem.pgPercentage.percentString
        stockField.text = inventoryItem.stock.amountString
        vgField.text = inventoryItem.vgPercentage.percentString
        if let manufacturer = inventoryItem.manufacturer { manufacturerField.text = manufacturer }
        if let orderAt = inventoryItem.orderAt { orderAtField.text = orderAt.amountString }
        stockField.textField.inputView = calculatorView
    }
    
    private func loadItem() {
        guard let item = itemToEdit else { return }
        nameField.text = item.name
        sizeField.text = item.size.amountString
        if let price = item.price { priceField.text = price.priceString }
    }
    
    private func loadPersonalRecipe() {
        guard let recipe = recipeToEdit else { return }
        nameField.text = recipe.name
        recipeIngredients = recipe.ingredients
        flavorsTable.reloadData()
    }
    
    @objc func showNotes(_ sender: UIButton?) {
        let textView = LMTextView(type: .notes)
        blurView = view.addBlurEffect()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blurView?.contentView.addGestureRecognizer(tap)
        
        notesView.anchor(to: blurView?.contentView,
                         top: blurView?.contentView.safeAreaLayoutGuide.topAnchor,
                         leading: blurView?.contentView.leadingAnchor,
                         trailing: blurView?.contentView.trailingAnchor,
                         bottom: blurView?.contentView.bottomAnchor,
                         padding: .init(top: 20, left: 20, bottom: 20, right: 20))
        
        if let notes = notes { textView.text = notes }
        textView.becomeFirstResponder()
        textView.parentVC = self
        textView.anchor(to: notesView,
                        top: notesView.topAnchor,
                        leading: notesView.leadingAnchor,
                        trailing: notesView.trailingAnchor,
                        bottom: notesView.bottomAnchor,
                        padding: .init(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        view.endEditing(true)
        blurView?.fadeAlphaOut()
    }
}

//--------------------------------------------
// MARK: - Table view data source and delegate
//--------------------------------------------
extension EditVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeIngredients.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < recipeIngredients.count {
            let cell = RecipeCell(delegate: self, ingredient: recipeIngredients[indexPath.row])
            return cell
        } else {
            let cell = RecipeCell(delegate: self, ingredient: nil)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == recipeIngredients.count {
            performSegue(withIdentifier: SegueID.addFlavor.rawValue, sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            self.deleteIngredient(at: indexPath.row)
        }
        delete.image = #imageLiteral(resourceName: "delete")
        
        let configuration = UISwipeActionsConfiguration.init(actions: [delete])
        return configuration
    }
    
    func deleteIngredient(at row: Int) {
        recipeIngredients.remove(at: row)
        flavorsTable.reloadData()
    }
}

extension EditVC: NewFlavorDelegate {
    func receive(_ inventoryItem: InventoryItem) {
        let newIngredient = Ingredient(item: inventoryItem, percent: nil, amount: nil)
        recipeIngredients.append(newIngredient)
        flavorsTable.reloadData()
    }
}
