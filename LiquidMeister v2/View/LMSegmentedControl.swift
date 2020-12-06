//
//  LMSegmentedControl.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/27/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class LMSegmentedControl: BetterSegmentedControl {
    var delegate: UIViewController!
    
    override init(frame: CGRect, titles: [String], index: UInt, options: [BetterSegmentedControlOption]?) {
        super.init(frame: frame, titles: titles, index: index, options: options)
    }
    
    convenience init(titles: [String]) {
        self.init(frame: .zero, titles: titles, index: 0, options: [
            BetterSegmentedControlOption.backgroundColor(Color.primaryBlack.color),
            BetterSegmentedControlOption.cornerRadius(10),
            BetterSegmentedControlOption.indicatorViewBackgroundColor(Color.white.color),
            BetterSegmentedControlOption.indicatorViewInset(3),
            BetterSegmentedControlOption.selectedTitleColor(Color.primaryBlack.color),
            BetterSegmentedControlOption.selectedTitleFont(UIFont(name: Font.bold, size: 22)!),
            BetterSegmentedControlOption.titleColor(Color.white.color),
            BetterSegmentedControlOption.titleFont(UIFont(name: Font.regular, size: 22)!),
            BetterSegmentedControlOption.titleNumberOfLines(1)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        self.layer.borderColor = Color.white.color.cgColor
        self.layer.borderWidth = 1
    }
    
    @objc func segmentChanged(_ sender: LMSegmentedControl?) {
        if let loginVC = delegate as? LoginVC {
            if sender?.index == 0 {
                loginVC.usernameField.fadeAlphaTo(1)
            } else {
                loginVC.usernameField.fadeAlphaTo(0)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
