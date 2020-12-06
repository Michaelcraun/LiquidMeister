//
//  UITableViewExtension.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/30/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

extension UITableView {
    func scrollToBottom(_ animated: Bool = true) {
        let sections = self.numberOfSections
        let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0){
            let indexPath = IndexPath(row: rows - 1, section: sections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension UITableViewCell {
    func clearCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}
