//
//  ViewController.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import TextFieldEffects

class LoginVC: UIViewController {
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
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = Color.primaryBlack.color
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "icon")
        imageView.layer.borderColor = Color.white.color.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "title")
        return imageView
    }()
    
    let loginControl = LMSegmentedControl(titles: ["Register", "Login"])
    let emailField = LMTextField(type: .email)
    let passwordField = LMTextField(type: .password)
    let usernameField = LMTextField(type: .username)
    let registerButton = LMButton(type: .register)
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        beginConnectionTest()
        layoutView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        DataManager.instance.delegate = self
        loginControl.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        usernameField.delegate = self
        registerButton.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HomeVC {
            slideInTransitioningDelegate.direction = .right
            slideInTransitioningDelegate.disableCompactHeight = false
            destination.transitioningDelegate = slideInTransitioningDelegate
            destination.modalPresentationStyle = .custom
        }
    }
    
    private func layoutView() {
        view.backgroundColor = Color.primaryBlue.color
//        view.bindToKeyboard()
        
        backgroundImageView.fillTo(view)
        
        iconImageView.anchor(to: view,
                              top: view.topAnchor,
                              centerX: view.centerXAnchor,
                              padding: .init(top: 20, left: 0, bottom: 0, right: 0),
                              size: .init(width: 150, height: 150))
        
        logoImageView.anchor(to: view,
                             top: iconImageView.bottomAnchor,
                             centerX: view.centerXAnchor,
                             padding: .init(top: 20, left: 0, bottom: 0, right: 0),
                             size: .init(width: 373, height: 69))
        
        loginControl.anchor(to: view,
                            top: logoImageView.bottomAnchor,
                            leading: view.leadingAnchor,
                            trailing: view.trailingAnchor,
                            padding: .init(top: 20, left: 10, bottom: 0, right: 10),
                            size: .init(width: 0, height: 40))
        
        emailField.anchor(to: view,
                          top: loginControl.bottomAnchor,
                          leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        passwordField.anchor(to: view,
                             top: emailField.bottomAnchor,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        usernameField.anchor(to: view,
                             top: passwordField.bottomAnchor,
                             leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             padding: .init(top: 10, left: 10, bottom: 0, right: 10))
        
        registerButton.anchor(to: view,
                           leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           padding: .init(top: 0, left: 10, bottom: 10, right: 10),
                           size: .init(width: 0, height: 40))
    }
}
