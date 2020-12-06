//
//  DataManager.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation
import Firebase

enum FIRKey: String {
    case sharedRecipes
    case users
    case usernames
    
    enum UserKey: String {
        case customers
        case inventory
        case items
        case providerID
        case recipes
        case username
        
        enum CustomerKey: String {
            case email
            case id
            case lastBottle
            case name
            case notes
            case nicotine
            case pg
            case vg
        }
        
        enum InventoryKey: String {
            case id
            case manufacturer
            case name
            case orderAt
            case stock
            case pg
            case vg
        }
        
        enum ItemKey: String {
            case id
            case name
            case price
            case size
        }
        
        enum RecipeKey: String {
            case favorite
            case id
            case ingredients
            case name
            case notes
            case rating
            case username
        }
    }
}

class DataManager {
    static var instance = DataManager()
    
    // MARK: - Completion handlers
    typealias Authorization = (Bool) -> Void
    typealias BottleInitialized = (Bool) -> Void
    typealias UserData = ([String : Any]) -> Void
    typealias Usernames = ([String]) -> Void
    
    // MARK: - Data variables
    var bottle = Bottle()
    var currentUserID: String?
    var delegate: UIViewController!
    var username: String?
    var missingIngredient: InventoryItem?
    var inventoryItemToDelete: InventoryItem?
    var affectedRecipes = [PersonalRecipe]()
    
    var customers = [Customer]() {
        didSet {
            customers = customers.sortByName()
        }
    }
    
    var inventory = [InventoryItem]() {
        didSet {
            inventory = inventory.sortByName()
        }
    }
    
    var items = [Item]() {
        didSet {
            items = items.sortByName()
        }
    }
    
    var recipes = [PersonalRecipe]() {
        didSet {
            recipes = recipes.sortByName()
        }
    }
    
    var sharedRecipes = [SharedRecipe]() {
        didSet {
            
        }
    }
    
    var REF_DATABASE: DatabaseReference
    var REF_USERS: DatabaseReference
    var REF_SHARED_RECIPES: DatabaseReference
    
    init() {
        currentUserID = Auth.auth().currentUser?.uid
        REF_DATABASE = Database.database().reference()
        REF_USERS = REF_DATABASE.child(FIRKey.users.rawValue)
        REF_SHARED_RECIPES = REF_DATABASE.child(FIRKey.sharedRecipes.rawValue)
        
        fetchUserData { (finished) in
            self.bottle.ingredients = self.bottle.fetchBaseIngredients()
        }
    }
    
    // MARK: - Data initialization functions
    func fetchUserData(_ completion: @escaping BottleInitialized) {
        guard let userID = currentUserID else { return }
        
        customers = []
        inventory = []
        items = []
        recipes = []
        
        fetchUserData(with: userID) { (userData) in
            let userCustomers = userData[FIRKey.UserKey.customers.rawValue] as? [String : Any] ?? [ : ]
            let userInventory = userData[FIRKey.UserKey.inventory.rawValue] as? [String : Any] ?? [ : ]
            let userItems = userData[FIRKey.UserKey.items.rawValue] as? [String : Any] ?? [ : ]
            let userRecipes = userData[FIRKey.UserKey.recipes.rawValue] as? [String : Any] ?? [ : ]
            let userUsername = userData[FIRKey.UserKey.username.rawValue] as? String ?? "No username listed"
            
            self.username = userUsername
            
            for value in userCustomers.values {
                if let dictionary = value as? [String : Any] {
                    let customer = dictionary.customer()
                    var shouldAdd = true
                    
                    for value in self.customers {
                        if value.id == customer.id {
                            shouldAdd = false
                            break
                        }
                    }
                    
                    if shouldAdd {
                        self.customers.append(dictionary.customer())
                    }
                }
            }
            
            for value in userInventory.values {
                if let dictionary = value as? [String : Any] {
                    let inventoryItem = dictionary.inventoryItem()
                    var shouldAdd = true
                    
                    for value in self.inventory {
                        if value.id == inventoryItem.id {
                            shouldAdd = false
                            break
                        }
                    }
                    
                    if shouldAdd {
                        self.inventory.append(dictionary.inventoryItem())
                    }
                }
            }
            
            for value in userItems.values {
                if let dictionary = value as? [String : Any] {
                    let item = dictionary.item()
                    var shouldAdd = true
                    
                    for value in self.items {
                        if value.id == item.id {
                            shouldAdd = false
                            break
                        }
                    }
                    
                    if shouldAdd {
                        self.items.append(dictionary.item())
                    }
                }
            }
            
            for value in userRecipes.values {
                if let dictionary = value as? [String : Any] {
                    let recipe = dictionary.personalRecipe()
                    var shouldAdd = true
                    
                    for value in self.recipes {
                        if value.id == recipe.id {
                            shouldAdd = false
                            break
                        }
                    }
                    
                    if shouldAdd {
                        self.recipes.append(dictionary.personalRecipe())   
                    }
                }
            }
            completion(true)
        }
    }
    
    //--------------------------------
    // MARK: - Authorization functions
    //--------------------------------
    func registerViaFirebase(email: String, password: String, username: String) {
        fetchUsernamesForRegistration({ (usernames) in
            if usernames.contains(username) {
                self.delegate.showAlert(.usernameExists)
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error == nil {
                        guard let user = user else { return }
                        let nicotine = InventoryItem(name: "Nicotine", orderAt: 125.0, stock: 0.0, pgPercentage: 50.0, vgPercentage: 50.0)
                        let pg = InventoryItem(name: "Propylene Glycol", orderAt: 250.0, stock: 0.0, pgPercentage: 100.0, vgPercentage: 0.0)
                        let vg = InventoryItem(name: "Vegetable Glycerin", orderAt: 250.0, stock: 0.0, pgPercentage: 0.0, vgPercentage: 100.0)
                        let userData: [String : Any] = [FIRKey.UserKey.providerID.rawValue : user.user.providerID,
                                                        FIRKey.UserKey.username.rawValue :   username,
                                                        FIRKey.UserKey.inventory.rawValue: [nicotine.dictionary(), pg.dictionary(), vg.dictionary()]]
                        
                        self.REF_USERS.child(user.user.uid).updateChildValues(userData)
                        self.updateUsernamesWithUsername(username)
                        self.delegate.performSegue(withIdentifier: SegueID.showHome.rawValue, sender: nil)
                    } else {
                        self.handleFIRAuthError(error)
                    }
                }
            }
        })
    }
    
    func loginViaFirebase(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                guard let user = user else { return }
                let userData: [String : Any] = [FIRKey.UserKey.providerID.rawValue : user.user.providerID]
                
                self.REF_USERS.child(user.user.uid).updateChildValues(userData)
                self.delegate.performSegue(withIdentifier: SegueID.showHome.rawValue, sender: nil)
            } else {
                self.handleFIRAuthError(error)
            }
        }
    }
    
    private func fetchUsernamesForRegistration(_ completion: @escaping Usernames) {
        var usernames = [String]()
        REF_DATABASE.observeSingleEvent(of: .value) { (snapshot) in
            guard let databaseSnapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for child in databaseSnapshot {
                if child.key == FIRKey.usernames.rawValue {
                    usernames = child.value as? [String] ?? [  ]
                }
            }
            completion(usernames)
        }
    }
    
    private func updateUsernamesWithUsername(_ username: String) {
        fetchUsernamesForRegistration { (usernames) in
            var takenUsernames = usernames
            takenUsernames.append(username)
            self.REF_DATABASE.updateChildValues([FIRKey.usernames.rawValue : [takenUsernames]])
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            delegate.performSegue(withIdentifier: SegueID.showLogin.rawValue, sender: nil)
        } catch let error {
            handleFIRAuthError(error)
        }
    }
    
    //---------------------------
    // MARK: - Database functions
    //---------------------------
    func updateFirebaseCustomer(_ customer: Customer) {
        REF_USERS.child(currentUserID!).child(FIRKey.UserKey.customers.rawValue).updateChildValues(customer.dictionary())
        delegate.dismiss(animated: true, completion: nil)
    }
    
    func updateFirebaseInventoryItem(_ inventoryItem: InventoryItem) {
        REF_USERS.child(currentUserID!).child(FIRKey.UserKey.inventory.rawValue).updateChildValues(inventoryItem.dictionary())
        delegate.dismiss(animated: true, completion: nil)
    }
    
    func updateFirebaseItem(_ item: Item) {
        REF_USERS.child(currentUserID!).child(FIRKey.UserKey.items.rawValue).updateChildValues(item.dictionary())
        delegate.dismiss(animated: true, completion: nil)
    }
    
    func updateFirebasePersonalRecipe(_ personalRecipe: PersonalRecipe) {
        REF_USERS.child(currentUserID!).child(FIRKey.UserKey.recipes.rawValue).updateChildValues(personalRecipe.dictionary())
        
        guard let _ = delegate as? LibraryVC else {
            delegate.dismiss(animated: true, completion: nil)
            return
        }
    }
    
    func removeFirebaseCustomer(_ customer: Customer) {
        REF_USERS.child(currentUserID!).child(FIRKey.UserKey.customers.rawValue).child(customer.id!).removeValue()
    }
    
    func removeFirebaseInventoryItem(_ inventoryItem: InventoryItem) {
        for recipe in affectedRecipes {
            var newIngredients = [Ingredient]()
            for ingredient in recipe.ingredients {
                if ingredient.item.id != inventoryItem.id {
                    newIngredients.append(ingredient)
                }
            }
            recipe.ingredients = newIngredients
            updateFirebasePersonalRecipe(recipe)
        }
        
        REF_USERS.child(currentUserID!).child(FIRKey.UserKey.inventory.rawValue).child(inventoryItem.id!).removeValue()
        
        inventoryItemToDelete = nil
        affectedRecipes = [  ]
    }
    
    func removeFirebaseItem(_ item: Item) {
        REF_USERS.child(currentUserID!).child(FIRKey.UserKey.items.rawValue).child(item.id!).removeValue()
    }
    
    func removeFirebasePersonalRecipe(_ personalRecipe: PersonalRecipe) {
        REF_USERS.child(currentUserID!).child(FIRKey.UserKey.recipes.rawValue).child(personalRecipe.id!).removeValue()
    }
    
    //---------------------------
    // MARK: - Observer functions
    //---------------------------
    private func fetchSharedRecipes() {
        REF_SHARED_RECIPES.observeSingleEvent(of: .value) { (snapshot) in
            // TODO: Fetch shared recipes from database
        }
    }
    
    // MARK: - Observers
    private func fetchUserData(with id: String, completion: @escaping UserData) {
        REF_USERS.observeSingleEvent(of: .value) { (snapshot) in
            guard let userSnapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for user in userSnapshot {
                if user.key == id {
                    let userData = user.value as? [String : Any] ?? [ : ]
                    completion(userData)
                }
            }
        }
    }
    
    //-----------------------
    // MARK: - Error handling
    //-----------------------
    private func handleFIRAuthError(_ error: Error?) {
        guard let errorCode = AuthErrorCode(rawValue: error!._code) else {
            delegate.showAlert(.firebaseError)
            return
        }
        
        switch errorCode {
        case .emailAlreadyInUse: delegate.showAlert(.firEmailAlreadyInUse)
        case .wrongPassword: delegate.showAlert(.firWrongPassword)
        case .invalidEmail: delegate.showAlert(.firInvalidEmail)
        case .userNotFound: delegate.showAlert(.firUserNotFound)
        default: delegate.showAlert(.firebaseError)
        }
    }
}
