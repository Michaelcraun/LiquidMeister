//
//  NotificationManager.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 7/10/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    var notificationAccessAllowed = true
    
    private enum NotificationKey: String {
        case lowInventory
    }
    
    /// Removes all notifications that have been presented to the user to keep things clean and storage space minimal,
    /// then checks if user has allowed notifications access or not. Must be called before application(_:didFinishLaunchingWithOptions)
    /// has finished.
    func checkAtStartup() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationKey.lowInventory.rawValue])
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if accepted {
                self.setNotificationCategories()
            } else {
                self.notificationAccessAllowed = false
            }
        }
    }
    
    private func setNotificationCategories() {
        let lowInventory = UNNotificationCategory(identifier: NotificationKey.lowInventory.rawValue, actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([lowInventory])
    }
    
    func scheduleOrderReminder() {
        let itemsToOrder = DataManager.instance.inventory.getNeedsOrdered()
        let dateComponents = configureOrderReminderDatComponents()
        if let content = configureOrderReminderContent(with: itemsToOrder) {
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: NotificationKey.lowInventory.rawValue, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("NOTIFICATION: Encountered error while adding notification request: \n\(error)")
                    return
                }
                print("NOTIFICATION: Scheduled notification successfully!")
            }
        } else {
            print("NOTIFICATION: No items need ordered.")
        }
    }
    
    private func configureOrderReminderDatComponents() -> DateComponents {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.hour = 9
        components.minute = 0
        return components
    }
    
    private func configureOrderReminderContent(with inventoryItems: [InventoryItem]) -> UNMutableNotificationContent? {
        guard let inventoryList = inventoryItems.list else { return nil }
        let content = UNMutableNotificationContent()
        content.body = "You're low on \(inventoryList). Did you order some?"
        content.categoryIdentifier = NotificationKey.lowInventory.rawValue
        content.sound = .default()
        content.title = "Low Inventory"
        return content
    }
    
    //MARK: Method that is called when the delivered notification is interacted with by the user
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        completionHandler()
    }
    
    //MARK: Method that is called when the notification is delivered and the application state is active
    internal func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
}
