//
//  LMTextView.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/28/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class LMTextView: UITextView {
    // MARK: - Layout variables
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.regular, size: 10)
        label.textColor = Color.white.color
        return label
    }()
    
    // MARK: - Data variables
    var parentVC: UIViewController!
    var type: ViewType?
    enum ViewType: String {
        case notes
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: .zero, textContainer: nil)
        self.delegate = self
    }
    
    convenience init(type: ViewType) {
        self.init(frame: .zero, textContainer: nil)
        self.type = type
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.primaryBlack.color
        self.font = UIFont(name: Font.regular, size: 18)
        self.textColor = Color.white.color
        self.layer.borderColor = Color.white.color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        
        if let type = type {
            placeholderLabel.text = "\(type.rawValue)..."
            
            placeholderLabel.anchor(to: self,
                                    leading: self.leadingAnchor,
                                    trailing: self.trailingAnchor,
                                    bottom: self.topAnchor,
                                    padding: .init(top: 0, left: 10, bottom: 0, right: 10))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LMTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        parentVC.view.addTapToDismissKeyboard()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        parentVC.view.removeTapToDismissKeyboard()
        
        if type! == .notes {
            if let editVC = parentVC as? EditVC, let notes = textView.text, notes != "" {
                editVC.notes = notes
            }
        }
    }
}
