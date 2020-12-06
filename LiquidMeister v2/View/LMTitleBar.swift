//
//  LMTitleBar.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/25/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class LMTitleBar: UIView {
    var delegate: UIViewController!
    var leftControlItem: UIButton?
    var rightControlItem: UIButton?
    
    let topView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white.color
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.regular, size: 22)
        label.text = "LiquidMeister"
        label.textAlignment = .center
        label.textColor = Color.white.color
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.regular, size: 10)
        label.textAlignment = .center
        label.textColor = Color.white.color
        return label
    }()
    
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white.color
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    override func layoutSubviews() {
        let settingsButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(controlItemPressed(_:)), for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(#imageLiteral(resourceName: "settingsIcon_white"), for: .normal)
            return button
        }()
        
        let backRightButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(controlItemPressed(_:)), for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(#imageLiteral(resourceName: "back_right"), for: .normal)
            return button
        }()
        
        let backLeftButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(controlItemPressed(_:)), for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(#imageLiteral(resourceName: "back_left"), for: .normal)
            return button
        }()
        
        let addButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(controlItemPressed(_:)), for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(#imageLiteral(resourceName: "addIcon"), for: .normal)
            return button
        }()
        
        let favoriteButton: UIButton = {
            let button = UIButton()
            button.addTarget(self, action: #selector(controlItemPressed(_:)), for: .touchUpInside)
            button.imageView?.contentMode = .scaleAspectFit
            button.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
            return button
        }()
        
        super.layoutSubviews()
        self.backgroundColor = Color.primaryBlack.color
        self.clipsToBounds = true
        
        topView.anchor(to: self,
                       top: self.topAnchor,
                       leading: self.leadingAnchor,
                       trailing: self.trailingAnchor,
                       size: .init(width: 0, height: 1))
        
        titleLabel.anchor(to: self,
                          top: self.topAnchor,
                          leading: self.leadingAnchor,
                          trailing: self.trailingAnchor,
                          padding: .init(top: 5, left: 5, bottom: 0, right: 5))
        
        subtitleLabel.anchor(to: self,
                             top: titleLabel.bottomAnchor,
                             leading: self.leadingAnchor,
                             trailing: self.trailingAnchor,
                             bottom: self.bottomAnchor,
                             padding: .init(top: 5, left: 5, bottom: 5, right: 5))
        
        bottomView.anchor(to: self,
                          leading: self.leadingAnchor,
                          trailing: self.trailingAnchor,
                          bottom: self.bottomAnchor,
                          size: .init(width: 0, height: 1))
        
        if let _ = delegate as? HomeVC {
            subtitleLabel.text = "CALCULATOR"
            leftControlItem = settingsButton
        } else if let _ = delegate as? SettingsVC {
            subtitleLabel.text = "SETTINGS"
            rightControlItem = backRightButton
        } else if let libraryVC = delegate as? LibraryVC {
            if let dataType = libraryVC.dataType {
                subtitleLabel.text = "\(dataType.rawValue.uppercased()) LIBRARY"
                leftControlItem = backLeftButton
                rightControlItem = addButton
            }
        } else if let editVC = delegate as? EditVC {
            if let dataType = editVC.dataType {
                subtitleLabel.text = "EDIT \(dataType.rawValue.uppercased())"
                leftControlItem = backLeftButton
                if dataType == .recipe {
                    rightControlItem = favoriteButton
                }
            }
        }
        
        if let leftItem = leftControlItem {
             leftItem.anchor(to: self,
                             leading: self.leadingAnchor,
                             centerY: self.centerYAnchor,
                             size: .init(width: 80, height: 30))
        }
        
        if let rightItem = rightControlItem {
            rightItem.anchor(to: self,
                             trailing: self.trailingAnchor,
                             centerY: self.centerYAnchor,
                             size: .init(width: 80, height: 30))
        }
    }
    
    @objc func controlItemPressed(_ sender: UIButton?) {
        switch sender?.image(for: .normal)! {
        case #imageLiteral(resourceName: "addIcon"): delegate.performSegue(withIdentifier: SegueID.showEdit.rawValue, sender: nil)
        case #imageLiteral(resourceName: "back_left"): delegate.dismiss(animated: true, completion: nil)
        case #imageLiteral(resourceName: "back_right"): delegate.dismiss(animated: true, completion: nil)
        case #imageLiteral(resourceName: "favorite_active"):
            if let editVC = delegate as? EditVC {
                editVC.recipeIsFavorite = false
                sender?.setImage(#imageLiteral(resourceName: "favorite"), for: .normal)
            }
        case #imageLiteral(resourceName: "favorite"):
            if let editVC = delegate as? EditVC {
                editVC.recipeIsFavorite = true
                sender?.setImage(#imageLiteral(resourceName: "favorite_active"), for: .normal)
            }
        case #imageLiteral(resourceName: "settingsIcon_white"): delegate.performSegue(withIdentifier: SegueID.showSettings.rawValue, sender: nil)
        default: break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
