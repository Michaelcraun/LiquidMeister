//
//  LMPickerView.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 6/29/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class PickerView: UIView {
    // MARK: - Layout variables
    let cancelButton = LMButton(type: .cancel)
    let doneButton = LMButton(type: .done)
    
    let controlBar: UIView = {
        let view = UIView()
        view.backgroundColor = Color.primaryBlack.color
        return view
    }()
    
    let dataPicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.backgroundColor = Color.primaryBlack.color
        return pickerView
    }()
    
    // MARK: - Data variables
    var type: PickerType?
    enum PickerType {
        case customer
        case item
        case recipe
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.anchor()
    }
    
    convenience init(type: PickerType) {
        self.init(frame: .zero)
        self.type = type
        
        dataPicker.dataSource = self
        dataPicker.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        controlBar.anchor(to: self,
                          top: self.topAnchor,
                          leading: self.leadingAnchor,
                          trailing: self.trailingAnchor,
                          padding: .init(top: 1, left: 0, bottom: 0, right: 0),
                          size: .init(width: 0, height: 44))
        
        cancelButton.anchor(to: controlBar,
                            leading: self.leadingAnchor,
                            centerY: self.centerYAnchor,
                            padding: .init(top: 0, left: 5, bottom: 0, right: 0),
                            size: .init(width: 100, height: 34))
        
        doneButton.anchor(to: controlBar,
                          trailing: self.trailingAnchor,
                          centerY: self.centerYAnchor,
                          padding: .init(top: 0, left: 0, bottom: 0, right: 5),
                          size: .init(width: 100, height: 34))
        
        dataPicker.anchor(to: self,
                          top: controlBar.bottomAnchor,
                          leading: self.leadingAnchor,
                          trailing: self.trailingAnchor,
                          bottom: self.bottomAnchor,
                          padding: .init(top: 1, left: 0, bottom: 0, right: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//---------------------------------------------
// MARK: - Picker view data source and delegate
//---------------------------------------------
extension PickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch type! {
        case .customer: return DataManager.instance.customers.count
        case .item: return DataManager.instance.items.count
        case .recipe: return DataManager.instance.recipes.count
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        <#code#>
//    }
}
