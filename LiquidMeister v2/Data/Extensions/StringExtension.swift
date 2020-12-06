//
//  StringExtension.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/25/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

extension String {
    func isFormattedForUsername() -> Bool {
        if self.contains(" ") {
            return false
        }
        return true
    }
    
    var amountString: String {
        guard let double = Double(self) else { return "0.0 mL" }
        return String(format: "%.01f mL", double)
    }
    
    var percentString: String {
        guard let double = Double(self) else { return "0.0%" }
        let formattedString = String(format: "%.01f", double)
        return "\(formattedString)%"
    }
    
    var priceString: String {
        guard let double = Double(self) else { return "$0.00" }
        return String(format: "$%.02f", double)
    }
    
    func removing(_ substring: String) -> String {
        var string = self 
        for character in substring {
            if let index = string.index(of: character) {
                string.remove(at: index)
            }
        }
        return string
    }
}
