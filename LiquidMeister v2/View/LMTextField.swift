//
//  LMTextField.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/27/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class LMTextField: UIView {
    // MARK: - Layout variables
    let placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.regular, size: 10)
        label.textColor = Color.white.color
        return label
    }()
    
    let textField: TextField = {
        let textField = TextField()
        textField.backgroundColor = Color.primaryBlack.color
        textField.font = UIFont(name: Font.regular, size: 18)
        textField.layer.borderColor = Color.white.color.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.shadowColor = Color.primaryBlack.color.cgColor
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowOpacity = 0.8
        textField.layer.shadowRadius = 10
        textField.textColor = Color.white.color
        return textField
    }()
    
    // MARK: - Data variables
    var delegate: UIViewController!
    var type: FieldType?
    enum FieldType: String {
        case amount
        case customer
        case email
        case ingredient
        case lastBottle = "last bottle"
        case manufacturer
        case name
        case newAmount = "new amount"
        case nicotine
        case orderAt = "order at"
        case password
        case percent
        case pg
        case price
        case recipe
        case size
        case stock
        case username
        case vg
    }
    
    var text: String? {
        didSet {
            if let text = text {
                textField.text = text
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    convenience init(type: FieldType) {
        self.init(frame: .zero)
        self.type = type
        
        placeHolderLabel.text = "\(type.rawValue)..."
        placeHolderLabel.anchor(to: self,
                                top: self.topAnchor,
                                leading: self.leadingAnchor,
                                trailing: self.trailingAnchor,
                                padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        
        switch type {
        case .amount: self.isUserInteractionEnabled = false
        case .email:
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.keyboardType = .emailAddress
        case .ingredient: textField.isUserInteractionEnabled = false
        case .lastBottle: textField.isUserInteractionEnabled = false
        case .name: textField.autocapitalizationType = .words
        case .newAmount: textField.isUserInteractionEnabled = false
        case .nicotine: textField.keyboardType = .decimalPad
        case .orderAt: textField.keyboardType = .decimalPad
        case .password:
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.isSecureTextEntry = true
        case .percent: textField.keyboardType = .decimalPad
        case .pg: textField.keyboardType = .decimalPad
        case .price: textField.keyboardType = .decimalPad
        case .size: textField.keyboardType = .decimalPad
        case .username:
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.keyboardType = .emailAddress
        case .vg: textField.keyboardType = .decimalPad
        default: break
        }
        
        textField.delegate = self
        textField.sizeToFit()
        textField.anchor(to: self,
                         top: placeHolderLabel.bottomAnchor,
                         leading: self.leadingAnchor,
                         trailing: self.trailingAnchor,
                         bottom: self.bottomAnchor,
                         padding: .init(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TextField: UITextField {
    private let padding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}

extension LMTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let homeVC = delegate as? HomeVC {
            if textField == homeVC.customerField.textField {
                homeVC.view.endEditing(true)
                homeVC.performSegue(withIdentifier: SegueID.addFlavor.rawValue, sender: "customer")
            } else if textField == homeVC.recipeField.textField {
                homeVC.view.endEditing(true)
                homeVC.performSegue(withIdentifier: SegueID.addFlavor.rawValue, sender: "recipe")
            } else if textField == homeVC.sizeField.textField {
                homeVC.view.endEditing(true)
                homeVC.performSegue(withIdentifier: SegueID.addFlavor.rawValue, sender: "item")
            } else {
                delegate.view.addTapToDismissKeyboard()
            }
        } else {
            delegate.view.addTapToDismissKeyboard()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        text = textField.text
        delegate.view.removeTapToDismissKeyboard()
        
        switch type! {
        case .amount: textField.text = text?.amountString
        case .nicotine: textField.text = text?.percentString
        case .orderAt: textField.text = text?.amountString
        case .percent: textField.text = text?.percentString
        case .pg: textField.text = text?.percentString
        case .price: textField.text = text?.priceString
        case .size: textField.text = text?.amountString
        case .stock: textField.text = text?.amountString
        case .vg: textField.text = text?.percentString
        default: break
        }
    }
}
