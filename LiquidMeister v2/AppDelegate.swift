//
//  AppDelegate.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let notificationManager = NotificationManager()
    var window: UIWindow?

    // TODO: Research weird problem where titlebar buttons are becoming unusable when user switches apps
    // This doesn't happen when using in-app functionality, like when pulling down on a Messages notification to respond to a message
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        notificationManager.checkAtStartup()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController = {
            if DataManager.instance.currentUserID == nil {
                return storyboard.instantiateViewController(withIdentifier: "LoginVC")
            } else {
                return storyboard.instantiateViewController(withIdentifier: "HomeVC")
            }
        }()
        
        self.window?.rootViewController? = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        notificationManager.checkAtStartup()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        notificationManager.scheduleOrderReminder()
    }
}
