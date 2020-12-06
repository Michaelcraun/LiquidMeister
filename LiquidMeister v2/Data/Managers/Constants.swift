//
//  Constants.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

enum Color {
    case primaryBlack
    case primaryBlue
    case secondaryBlack
    case secondaryBlue
    case white
    
    var color: UIColor {
        switch self {
        case .primaryBlack: return UIColor(red: 13 / 255, green: 13 / 255, blue: 13 / 255, alpha: 1)
        case .primaryBlue: return UIColor(red: 0 / 255, green: 0 / 255, blue: 63 / 255, alpha: 1)
        case .secondaryBlack: return UIColor(red: 38 / 255, green: 38 / 255, blue: 38 / 255, alpha: 1)
        case .secondaryBlue: return UIColor(red: 0 / 255, green: 0 / 255, blue: 114 / 255, alpha: 1)
        case .white: return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
        }
    }
}

enum DataType: String {
    case customer
    case inventory
    case item
    case recipe
}

enum Font {
    static let bold = "\(regular)-Bold"
    static let regular = "TrebuchetMS"
}

enum Measurements {
    static var topBannerHeight: CGFloat {
        switch UIDevice.current.modelName {
        case "iPhone X": return 88
        default: return 64
        }
    }
}

enum SegueID: String {
    case addFlavor
    case showEdit
    case showHome
    case showLibrary
    case showLogin
    case showSettings
}
