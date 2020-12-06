//
//  LMCalculator.swift
//  LiquidMeister v2
//
//  Created by Michael Craun on 7/6/18.
//  Copyright © 2018 CraunicProductions. All rights reserved.
//

import UIKit

class LMCaclulatorView: UIView {
    // MARK: - Layout variables
    let calculationField = LMTextField(type: .newAmount)
    let zeroButton = CalculatorButton(operand: .zero)
    let oneButton = CalculatorButton(operand: .one)
    let twoButton = CalculatorButton(operand: .two)
    let threeButton = CalculatorButton(operand: .three)
    let fourButton = CalculatorButton(operand: .four)
    let fiveButton = CalculatorButton(operand: .five)
    let sixButton = CalculatorButton(operand: .six)
    let sevenButton = CalculatorButton(operand: .seven)
    let eightButton = CalculatorButton(operand: .eight)
    let nineButton = CalculatorButton(operand: .nine)
    let decimalButton = CalculatorButton(operand: .decimal)
    let plusButton = CalculatorButton(operand: .plus)
    let minusButton = CalculatorButton(operand: .minus)
    let equalsButton = CalculatorButton(operand: .equals)
    
    // MARK: - Data variables
    var delegate: UIViewController!
    var textField: LMTextField!
    var inventoryItem: InventoryItem?
//    var initialValue: Double!
//    var currentAmount: Double!
    var leftValue = "0.0"
    var runningValue = ""
    var newAmount = 0.0
    var currentOperation: Operation = .none
    
    var calculationString = "" {
        didSet {
            calculationField.text = calculationString
        }
    }
    
    enum Operation: String {
        case add = "+"
        case subtract = "-"
        case none
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        zeroButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        oneButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        twoButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        threeButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        fourButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        fiveButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        sixButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        sevenButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        eightButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        nineButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        decimalButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        equalsButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
    }
    
    convenience init(delegate: UIViewController, textField: LMTextField, inventoryItem: InventoryItem?) {
        self.init(frame: .zero)
        self.delegate = delegate
        self.textField = textField
        self.inventoryItem = inventoryItem
        leftValue = "\(inventoryItem?.stock ?? 0.0)"
        calculationString = "\(inventoryItem?.stock ?? 0.0)"
        calculationField.text = "\(inventoryItem?.stock ?? 0.0)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.primaryBlue.color
        
        let topView: UIView = {
            let view = UIView()
            view.backgroundColor = Color.primaryBlack.color
            return view
        }()
        
        let horizontalStack: UIStackView = {
            let stackView = UIStackView()
            stackView.addArrangedSubview(oneButton)
            stackView.addArrangedSubview(twoButton)
            stackView.addArrangedSubview(threeButton)
            stackView.alignment = .center
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
        
        let horizontalStack1: UIStackView = {
            let stackView = UIStackView()
            stackView.addArrangedSubview(fourButton)
            stackView.addArrangedSubview(fiveButton)
            stackView.addArrangedSubview(sixButton)
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
        
        let horizontalStack2: UIStackView = {
            let stackView = UIStackView()
            stackView.addArrangedSubview(sevenButton)
            stackView.addArrangedSubview(eightButton)
            stackView.addArrangedSubview(nineButton)
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
        
        let horizontalStack3: UIStackView = {
            let stackView = UIStackView()
            stackView.addArrangedSubview(decimalButton)
            stackView.addArrangedSubview(zeroButton)
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
        
        let horizontalStack4: UIStackView = {
            let stackView = UIStackView()
            stackView.addArrangedSubview(plusButton)
            stackView.addArrangedSubview(minusButton)
            stackView.addArrangedSubview(equalsButton)
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
        
        let verticalStack: UIStackView = {
            let stackView = UIStackView()
            stackView.addArrangedSubview(calculationField)
            stackView.addArrangedSubview(horizontalStack)
            stackView.addArrangedSubview(horizontalStack1)
            stackView.addArrangedSubview(horizontalStack2)
            stackView.addArrangedSubview(horizontalStack3)
            stackView.addArrangedSubview(horizontalStack4)
            stackView.alignment = .fill
            stackView.axis = .vertical
            stackView.backgroundColor = Color.primaryBlue.color
            stackView.distribution = .fillEqually
            stackView.spacing = 5
            return stackView
        }()
        
        topView.anchor(to: self,
                       top: self.topAnchor,
                       leading: self.leadingAnchor,
                       trailing: self.trailingAnchor,
                       size: .init(width: 0, height: 1))
        
        verticalStack.anchor(to: self,
                             top: self.topAnchor,
                             leading: self.leadingAnchor,
                             trailing: self.trailingAnchor,
                             bottom: self.bottomAnchor,
                             padding: .init(top: 5, left: 5, bottom: 5, right: 5))
    }
    
    @objc func buttonPressed(_ sender: CalculatorButton?) {
        guard let sender = sender else { return }
        switch sender.tag {
        case 10:
            calculationString += " + "
            processOperation(.add)
        case 11:
            calculationString += " - "
            processOperation(.subtract)
        case 12:
            processOperation(currentOperation)
            inventoryItem?.stock = newAmount
            textField.text = "\(newAmount)"
            currentOperation = .none
            leftValue = "\(newAmount)"
            calculationString = "\(newAmount)"
            runningValue = ""
            delegate.view.endEditing(true)
        case 13:
            calculationString += "."
            runningValue += "."
        default:
            runningValue += "\(sender.tag)"
            calculationString += "\(sender.tag)"
        }
    }
    
    private func processOperation(_ operation: Operation) {
        let rightNumber = Double(runningValue) ?? 0.0
        let leftNumber = Double(leftValue) ?? 0.0
        var result = 0.0
        
        switch operation {
        case .add: result = leftNumber + rightNumber
        case .subtract: result = leftNumber - rightNumber
        case .none: break
        }
        
        currentOperation = operation
        runningValue = ""
        leftValue = "\(result)"
        newAmount = result
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CalculatorButton: UIButton {
    // MARK: - Data variables
    var operand: Operand!
    enum Operand: Int {
        case decimal = 13
        case eight = 8
        case equals = 12
        case five = 5
        case four = 4
        case minus = 11
        case nine = 9
        case one = 1
        case plus = 10
        case seven = 7
        case six = 6
        case three = 3
        case two = 2
        case zero = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    convenience init(operand: Operand) {
        self.init(frame: .zero)
        self.operand = operand
        self.tag = operand.rawValue
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = Color.primaryBlack.color
        self.layer.borderColor = Color.white.color.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        
        switch operand! {
        case .decimal:  self.setTitle(".", for: .normal)
        case .equals:   self.setTitle("=", for: .normal)
        case .minus:    self.setTitle("-", for: .normal)
        case .plus:     self.setTitle("+", for: .normal)
        default:        self.setTitle("\(operand.rawValue)", for: .normal)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
