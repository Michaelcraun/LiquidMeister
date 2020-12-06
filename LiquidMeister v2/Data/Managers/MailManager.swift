//
//  MailManager.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 7/4/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation
import MessageUI

class MailManager: NSObject, MFMailComposeViewControllerDelegate {
    let defaults = UserDefaults.standard
    var delegate: UIViewController!
    var canSendMail = false
    
    override init() {
        super.init()
        
        checkCanSendMail()
    }
    
    func checkCanSendMail() {
        if MFMailComposeViewController.canSendMail() {
            canSendMail = true
        }
    }
    
    func sendInvoiceToCustomer(for bottle: Bottle) {
        if canSendMail {
            let composeVC = MFMailComposeViewController()
            let messageInfo = configureInvoiceMessage(for: bottle)
            composeVC.mailComposeDelegate = self
            composeVC.setSubject(messageInfo["subject"] ?? "LiquidMeister Invoice")
            composeVC.setToRecipients([bottle.customer!.email!])
            composeVC.setMessageBody(messageInfo["body"] ?? "Your bottle of e-liquid is done.", isHTML: false)
            
            delegate.present(composeVC, animated: true, completion: nil)
        } else {
            delegate.showAlert(.cannotSendMail)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error { return }
        switch result {
        case .failed: delegate.showAlert(.sendFailed)
        case .sent: increaseInvoiceNumber()
        default: break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func configureInvoiceMessage(for bottle: Bottle) -> [String : String] {
        guard let customer = bottle.customer else { return [ : ] }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        var messageDict = [String : String]()
        let dateString = dateFormatter.string(from: date)
        let invoiceString = defaults.string(forKey: "invoiceNumber") ?? "000000"
        let recipeName = bottle.recipe?.name ?? "e-liquid"
        
        messageDict["subject"] = "Invoice #\(invoiceString) to \(customer.name)"
        messageDict["body"] =
        """
        Invoice #\(invoiceString)
        \(dateString)
        Hello, \(customer.name)!
        Just a quick invoice to remind you that you owe me \(bottle.price.priceString) for the \(bottle.size.amountString) bottle of \(recipeName) that I made you.
        
        Thank you for resolving this invoice as soon as possible!
        """
        
        return messageDict
    }
    
    private func increaseInvoiceNumber() {
        if let currentInvoiceString = defaults.string(forKey: "invoiceNumber") {
            if let currentInvoiceNumber = Int(currentInvoiceString) {
                let newInvoiceNumber = currentInvoiceNumber + 1
                var newInvoiceString = "\(newInvoiceNumber)"
                repeat {
                    newInvoiceString = "0\(newInvoiceString)"
                } while (newInvoiceString.count < 8)
                
                defaults.set(newInvoiceString, forKey: "invoiceNumber")
            }
        }
    }
}
