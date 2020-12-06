//
//  UIViewExtension.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/24/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

//----------------------
//MARK: - Layout methods
//----------------------
extension UIView {
    /// Sets the given view's top, leading, trailing, bottom, centerX, centerY, width, and height constraints
    /// - parameter top: An NSLayoutYAxisAnchor to constrain the given view to (defaults to nil)
    /// - parameter leading: An NSLayoutXAxisAnchor to constrain the given view to (defaults to nil)
    /// - parameter trailing: An NSLayoutXAxisAnchor to constrain the given view to (defaults to nil)
    /// - parameter bottom: An NSLayoutYAxisAnchor to constrain the given view to (defaults to nil)
    /// - parameter centerX: An NSLayoutXAxisAnchor to constrain the given view to (defaults to nil)
    /// - parameter centerY: An NSLayoutYAxisAnchor to constrain the given view to (defaults to nil)
    /// - parameter padding: UIEdgeInsets representing the buffer between to top, leading, trailing, and
    /// bottom constraints (defaults to .zero)
    /// - parameter size: A CGSize value representing the desired size of the view (defaults to .zero)
    func anchor(to view: UIView? = nil, top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil,
                centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil,
                padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        if let view = view { view.addSubview(self) }
        
        if let top = top { topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true }
        if let leading = leading { leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true }
        if let trailing = trailing { trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true }
        if let bottom = bottom { bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true }
        
        if let centerX = centerX { centerXAnchor.constraint(equalTo: centerX).isActive = true }
        if let centerY = centerY { centerYAnchor.constraint(equalTo: centerY).isActive = true }
        
        if size.width != 0 { widthAnchor.constraint(equalToConstant: size.width).isActive = true }
        if size.height != 0 { heightAnchor.constraint(equalToConstant: size.height).isActive = true }
    }
    
    /// Constrains the given view to the top, leading, trailing, and bottom of the designated view with
    /// a designated amount of padding and size
    /// - parameter view: The view to constrain the given view to
    /// - parameter padding: UIEdgeInsets representing the buffer between the top, leading, trailing, and
    /// bottom edges of the given view and the edges of view constraining to (defaults to .zero)
    /// - parameter size: A CGSize value representing the desired size of the given view (defaults to .zero).
    /// If given a size, the view being constrained to should automatically adjust it's size
    func fillTo(_ view: UIView, withPadding padding: UIEdgeInsets = .zero, andSize size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding.left).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding.right).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom).isActive = true
        
        if size.width != 0 { widthAnchor.constraint(equalToConstant: size.width).isActive = true }
        if size.height != 0 { heightAnchor.constraint(equalToConstant: size.height).isActive = true }
    }
}

//--------------------------
// MARK: - Animation methods
//--------------------------
extension UIView {
    func addBlurEffect() -> UIVisualEffectView {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = UIScreen.main.bounds
            blurEffectView.tag = 1001
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.addSubview(blurEffectView)
        return blurEffectView
    }
    
    func fadeAlphaTo(_ alpha: CGFloat, with duration: TimeInterval = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = alpha
        }) { (finished) in
            if alpha == 0 {
                self.isUserInteractionEnabled = false
            } else {
                self.isUserInteractionEnabled = true
            }
        }
    }
    
    func fadeAlphaOut() {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }, completion: { (finished) in
            self.removeFromSuperview()
        })
    }
}

//-------------------------
// MARK: - Keyboard control
//-------------------------
extension UIView {
    /// Adds a tap gesture to the specified view to dismiss the keyboard
    func addTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(sender:)))
        self.addGestureRecognizer(tap)
    }
    
    /// Dismisses the keyboard when the user taps the view
    /// - parameter sender: The UITapGestureRecognizer associated with the function
    @objc private func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    func removeTapToDismissKeyboard() {
        for recognizer in self.gestureRecognizers ?? [] {
            self.removeGestureRecognizer(recognizer)
        }
    }
    
    @objc dynamic func handleTap(recognizer: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let offset = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if self.frame.maxY == UIScreen.main.bounds.height {
            self.frame.origin.y -= offset.height - 100
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.frame.maxY != UIScreen.main.bounds.height {
                self.frame.origin.y += keyboardSize.height - 100
            }
        }
    }
}
