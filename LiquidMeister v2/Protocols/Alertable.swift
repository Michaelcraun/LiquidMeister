//
//  Alertable.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/25/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

enum AlertType {
    case affectedRecipes
    case bottleCreated
    case bottleCreatedWithEmail
    case cannotSendMail
    case createRecipe
    case creationFailed
    case existingCustomer
    case existingInventoryItem
    case existingItem
    case existingRecipe
    case ingredientError
    case invalidEmail
    case invalidPassword
    case invalidUsername
    case missingIngredients
    case missingName
    case missingSize
    case missingStock
    case notEnoughIngredient
    case percentageError
    case recipeExists
    case sendFailed
    case usernameExists
    
    case firebaseError
    case firEmailAlreadyInUse
    case firWrongPassword
    case firInvalidEmail
    case firUserNotFound
    
    var title: String {
        switch self {
        case .bottleCreated: return "Success!"
        case .bottleCreatedWithEmail: return "Success!"
        case .createRecipe: return "Name, Please!"
        case .firebaseError: return "Firebase Error:"
        case .firEmailAlreadyInUse: return AlertType.firebaseError.title
        case .firWrongPassword: return AlertType.firebaseError.title
        case .firInvalidEmail: return AlertType.firebaseError.title
        case .firUserNotFound: return AlertType.firebaseError.title
        default: return "Error:"
        }
    }
    
    var message: String {
        switch self {
        case .affectedRecipes: return "\(DataManager.instance.affectedRecipes.count) recipes will be affected by this deletion. Are you sure you want to continue?"
        case .bottleCreated: return "Awesome! This bottle has been created and it's contents have been reduced from your inventory!"
        case .bottleCreatedWithEmail: return "Awesome! This bottle has been created and it's contents have been reduced from your inventory! Would you like to send the customer an invoice?"
        case .cannotSendMail: return "Hmm... Looks like your device isn't able to send e-mails! Please configure your device to send e-mails and try again!"
        case .createRecipe: return "Please name this recipe:"
        case .creationFailed: return "Oh, noes! Something went wrong and we weren't able to create this bottle! Please make sure the bottle's size is designated, the bottle has at least one flavor, and the percentages are filled out on each ingredient and try again."
        case .existingCustomer: return "Oh, noes! That customer already exists! Please try again."
        case .existingInventoryItem: return "Oh, noes! That inventory item already exists! Please try again."
        case .existingItem: return "Oh, noes! That item already exists! Please try again."
        case .existingRecipe: return "Oh, noes! That recipe already exists! Please try again."
        case .ingredientError: return "Oh, noes! There aren't enough ingredients to make that! Please try again."
        case .invalidEmail: return "Oh, noes! That doesn't look like an actual email! Please try again."
        case .invalidPassword: return "Oh, noes! Looks like you didn't enter a password! Please try again."
        case .invalidUsername: return "Oh, noes! Usernames shouldn't contain spaces! Please try again."
        case .missingIngredients: return "Oh, noes! Your ingredients are missing! Please try again."
        case .missingName: return "Oh, noes! That entry is missing a name! Please try again."
        case .missingSize: return "Oh, noes! That entry is missing a size! Please try again."
        case .missingStock: return "Oh, noes! You forgot the stock! Please try again."
        case .notEnoughIngredient: return "Oh, noes! You don't have enough stock of \(DataManager.instance.missingIngredient?.name ?? "ERROR!")!"
        case .percentageError: return "Oh, noes! Looks like the percentages for your your ingredients are missing or aren't actual numbers! Please try again."
        case .recipeExists: return "Oh, noes! Looks like that recipe already exists! Please try again."
        case .sendFailed: return "Oh, noes! Something went wrong and your invoice wasn't sent. Please try again from the Mail app."
        case .usernameExists: return "Oh, noes! That username already exists! Please try a new one."
            
        case .firebaseError: return "Oh, noes! There was an unexpected error with Firebase! Please try again."
        case .firEmailAlreadyInUse: return "Oh, noes! That email is alread in use! Please try again."
        case .firWrongPassword: return "Oh, noes! Looks like you used the wrong password! Please try again."
        case .firInvalidEmail: return "Oh, noes! That doesn't look like an actual email! Please try again."
        case .firUserNotFound: return "Oh, noes! Doesn't look like that user exists! Would you like to register?"
            
        default: return "Oh, noes! An unexpected error occured. Please try again."
        }
    }
    
    var notificationType: NotificationType {
        switch self {
        case .affectedRecipes: return .warning
        case .bottleCreated: return .success
        case .bottleCreatedWithEmail: return .success
        default: return .error
        }
    }
    
    var needsOptions: Bool {
        switch self {
        case .affectedRecipes: return true
        case .bottleCreatedWithEmail: return true
        case .createRecipe: return true
        case .firUserNotFound: return true
        default: return false
        }
    }
    
    var needsTextFields: Bool {
        switch self {
        case .createRecipe: return true
        default: return false
        }
    }
}

enum NotificationDevice {
    case haptic
    case vibrate
    case none
}

enum NotificationType {
    case error
    case success
    case warning
}

protocol Alertable {  }

extension Alertable where Self: UIViewController {
    func showAlert(_ type: AlertType) {
        var defaultActionTitle: String {
            switch type {
            case .affectedRecipes: return "No"
            case .bottleCreatedWithEmail: return "No"
            case .createRecipe: return "Cancel"
            case .firUserNotFound: return "No"
            default: return "OK"
            }
        }
        
        var defaultActionType: UIAlertActionStyle {
            switch type {
            case .affectedRecipes: return .cancel
            case .bottleCreatedWithEmail: return .cancel
            case .createRecipe: return .cancel
            case .firUserNotFound: return .cancel
            default: return .default
            }
        }
        
        var secondaryActionTitle: String {
            switch type {
            case .createRecipe: return "OK"
            default: return "Yes"
            }
        }
        
        let _ = view.addBlurEffect()
        addVibration(withNotificationType: type.notificationType)
        
        let alertController = UIAlertController(title: type.title, message: type.message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: defaultActionTitle, style: defaultActionType) { (action) in
            self.dismissAlert()
        }
        
        let yesAction = UIAlertAction(title: secondaryActionTitle, style: .default) { (action) in
            self.dismissAlert()
            
            if type == .affectedRecipes {
                DataManager.instance.removeFirebaseInventoryItem(DataManager.instance.inventoryItemToDelete!)
            } else if type == .bottleCreatedWithEmail {
                let mailManager = MailManager()
                mailManager.delegate = self
                mailManager.sendInvoiceToCustomer(for: DataManager.instance.bottle)
            } else if type == .createRecipe {
                guard let recipeName = alertController.textFields![0].text else {
                    self.showAlert(.createRecipe)
                    return
                }
                DataManager.instance.bottle.newRecipeName = recipeName
                DataManager.instance.bottle.createRecipe()
            } else if type == .firUserNotFound {
                if let loginVC = self as? LoginVC {
                    try! loginVC.loginControl.setIndex(0)
                }
            } else if type == .notEnoughIngredient {
                DataManager.instance.missingIngredient = nil
            }
        }
        
        alertController.addAction(defaultAction)
        if type.needsOptions { alertController.addAction(yesAction) }
        if type.needsTextFields {
            alertController.addTextField { (recipeNameField) in
                recipeNameField.font = UIFont(name: Font.regular, size: 22)
            }
        }
        
        present(alertController, animated: false, completion: nil)
    }
    
    func addVibration(withNotificationType type: NotificationType) {
        var notificationDevice: NotificationDevice {
            switch UIDevice.current.modelName {
            case "iPhone 6", "iPhone 6 Plus", "iPhone 6s", "iPhone 6s Plus", "iPhone 7", "iPhone 7 Plus", "iPhone 8", "iPhone 8 Plus", "iPhone X": return .haptic
            case "iPod Touch 5", "iPod Touch 6", "iPhone 4", "iPhone 5", "iPhone 5c", "iPhone 5s", "iPhone SE": return .vibrate
            default: return .none
            }
        }
        
        switch notificationDevice {
        case .haptic:
            let notification = UINotificationFeedbackGenerator()
            switch type {
            case .error: notification.notificationOccurred(.error)
            case .success: notification.notificationOccurred(.success)
            case .warning: notification.notificationOccurred(.warning)
            }
        case .vibrate:
            let vibrate = SystemSoundID(kSystemSoundID_Vibrate)
            switch type {
            default: break
            }
        default: break
        }
    }
    
    func dismissAlert() {
        for subview in self.view.subviews {
            if subview.tag == 1001 {
                subview.fadeAlphaOut()
            }
        }
    }
}


