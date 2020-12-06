//
//  DoubleExtension.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/30/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import Foundation

extension Double {
    var amountString: String {
        return String(format: "%.01f mL", self)
    }
    
    var percentString: String {
        let formattedString = String(format: "%.01f", self)
        return "\(formattedString)%"
    }
    
    var priceString: String {
        return String(format: "$%.02f", self)
    }
}
