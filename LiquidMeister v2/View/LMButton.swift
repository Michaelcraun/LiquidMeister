//
//  LMButton.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/27/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class LMButton: UIButton {
    var delegate: UIViewController!
    
    var type: LMButtonType?
    enum LMButtonType: String {
        case addFlavor = "add flavor"
        case calculate
        case cancel
        case createBottle = "create bottle"
        case createRecipe = "create recipe"
        case customers
        case done
        case email = "email customer"
        case inventory
        case items
        case logout
        case recipes
        case register = "register/login"
        case save
    }
    
    convenience init(type: LMButtonType) {
        self.init(frame: .zero)
        self.type = type
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        self.backgroundColor = Color.primaryBlack.color
        self.layer.borderColor = Color.white.color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        self.layer.shadowColor = Color.primaryBlack.color.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 10
        self.tintColor = Color.white.color
        self.titleLabel?.font = UIFont(name: Font.bold, size: 22)
        
        if let type = type {
            self.setTitle(type.rawValue.uppercased(), for: .normal)
            
            switch type {
            case .addFlavor: self.isUserInteractionEnabled = false
            default: break
            }
        }
    }
    
    @objc func buttonPressed(_ sender: LMButton?) {
        if let loginVC = delegate as? LoginVC {
            guard let email = loginVC.emailField.text, email != "" else {
                loginVC.showAlert(.invalidEmail)
                return
            }
            
            guard let password = loginVC.passwordField.text, password != "" else {
                loginVC.showAlert(.invalidPassword)
                return
            }
            
            if loginVC.loginControl.index == 0 {
                guard let username = loginVC.usernameField.text, username != "" && username.isFormattedForUsername() else {
                    loginVC.showAlert(.invalidUsername)
                    return
                }
                DataManager.instance.registerViaFirebase(email: email, password: password, username: username)
            } else {
                DataManager.instance.loginViaFirebase(email: email, password: password)
            }
        } else if let homeVC = delegate as? HomeVC {
            guard let button = sender else { return }
            if button == homeVC.createButton {
                if DataManager.instance.bottle.contentIsValid() {
                    DataManager.instance.bottle.reduceFromInventory()
                    if let customer = DataManager.instance.bottle.customer {
                        customer.lastBottle = DataManager.instance.bottle.description
                        DataManager.instance.updateFirebaseCustomer(customer)
                        if customer.email == nil {
                            homeVC.showAlert(.bottleCreated)
                        } else {
                            homeVC.showAlert(.bottleCreatedWithEmail)
                        }
                    } else {
                        homeVC.showAlert(.bottleCreated)
                    }
                    DataManager.instance.fetchUserData { (_) in }
                } else {
                    homeVC.showAlert(.creationFailed)
                }
            } else if button == homeVC.createRecipeButton {
                if DataManager.instance.bottle.ingredients.count > 3 {
                    homeVC.showAlert(.createRecipe)
                } else {
                    homeVC.showAlert(.ingredientError)
                }
            }
        } else if let settingsVC = delegate as? SettingsVC {
            guard let button = sender else { return }
            if button == settingsVC.logoutButton {
                DataManager.instance.logout()
            } else {
                settingsVC.performSegue(withIdentifier: SegueID.showLibrary.rawValue, sender: button)
            }
        } else if let editVC = delegate as? EditVC {
            editVC.saveData()
        }
    }
}
