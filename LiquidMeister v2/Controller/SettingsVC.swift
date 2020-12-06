//
//  SettingsVC.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/26/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
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
    let customersButton = LMButton(type: .customers)
    let inventoryButton = LMButton(type: .inventory)
    let itemsButton = LMButton(type: .items)
    let recipesButton = LMButton(type: .recipes)
    let logoutButton = LMButton(type: .logout)
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    let signedInLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.regular, size: 18)
        label.text = "signed in as"
        label.textAlignment = .center
        label.textColor = Color.white.color
        return label
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.bold, size: 18)
        label.textAlignment = .center
        label.textColor = Color.white.color
        if let username = DataManager.instance.username { label.text = username }
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beginConnectionTest()
        layoutView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DataManager.instance.delegate = self
        lmTitleBar.delegate = self
        customersButton.delegate = self
        inventoryButton.delegate = self
        itemsButton.delegate = self
        recipesButton.delegate = self
        logoutButton.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LibraryVC {
            slideInTransitioningDelegate.direction = .right
            slideInTransitioningDelegate.disableCompactHeight = false
            destination.transitioningDelegate = slideInTransitioningDelegate
            destination.modalPresentationStyle = .custom
            
            guard let sender = sender as? LMButton, let type = sender.type else { return }
            switch type {
            case .customers: destination.dataType = DataType(rawValue: "customer")
            case .inventory: destination.dataType = DataType(rawValue: "inventory")
            case .items: destination.dataType = DataType(rawValue: "item")
            case .recipes: destination.dataType = DataType(rawValue: "recipe")
            default: break
            }
        }
    }
    
    private func layoutView() {
        view.backgroundColor = Color.primaryBlue.color
        
        backgroundImageView.fillTo(view)
        
        lmTitleBar.anchor(to: view,
                          top: view.safeAreaLayoutGuide.topAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor)
        
        customersButton.anchor(to: view,
                               top: lmTitleBar.bottomAnchor,
                               leading: view.leadingAnchor,
                               trailing: view.trailingAnchor,
                               padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                               size: .init(width: 0, height: 40))
        
        inventoryButton.anchor(to: view,
                               top: customersButton.bottomAnchor,
                               leading: view.leadingAnchor,
                               trailing: view.trailingAnchor,
                               padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                               size: .init(width: 0, height: 40))
        
        itemsButton.anchor(to: view,
                           top: inventoryButton.bottomAnchor,
                           leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                           size: .init(width: 0, height: 40))
        
        recipesButton.anchor(to: view,
                             top: itemsButton.bottomAnchor,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             padding: .init(top: 10, left: 10, bottom: 0, right: 10),
                             size: .init(width: 0, height: 40))
        
        logoutButton.anchor(to: view,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            bottom: view.bottomAnchor,
                            padding: .init(top: 0, left: 10, bottom: 10, right: 10),
                            size: .init(width: 0, height: 40))
        
        usernameLabel.anchor(to: view,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             bottom: logoutButton.topAnchor,
                             padding: .init(top: 0, left: 10, bottom: 10, right: 10))
        
        signedInLabel.anchor(to: view,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             bottom: usernameLabel.topAnchor,
                             padding: .init(top: 0, left: 10, bottom: 0, right: 10))
    }
}
