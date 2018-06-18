//
//  Calculator.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 6/10/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class Calculator: MacApp {
    
    var desktopIcon: UIImage?
    
    var identifier: String? = "calculator"
    
    var windowTitle: String? = "Calculator"
    
    var menuActions: [MenuAction]?
    
    var contentMode: ContentStyle = .light
    
    lazy var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    var calculatorView : CalculatorView!
    
    init() {
        calculatorView = CalculatorView()
        calculatorView.delegate = self
        calculatorView.layer.cornerRadius = 2
        calculatorView.layer.masksToBounds = true
        
        let main = UIView()
        main.backgroundColor = .clear
        main.addSubview(calculatorView)
        calculatorView.translatesAutoresizingMaskIntoConstraints = false
        calculatorView.topAnchor.constraint(equalTo: main.topAnchor, constant: 2).isActive = true
        calculatorView.leftAnchor.constraint(equalTo: main.leftAnchor, constant: 2).isActive = true
        calculatorView.bottomAnchor.constraint(equalTo: main.bottomAnchor, constant: -2).isActive = true
        calculatorView.rightAnchor.constraint(equalTo: main.rightAnchor, constant: -2).isActive = true
        container = main
    }
    
    var container: UIView?
    
    func willTerminateApplication() {
        
    }
    
    func willLaunchApplication(in view: AZDesktop, withApplication app: AZApplication) {
        
    }
    
    func sizeForWindow() -> CGSize {
        return SystemSettings.calculatorSize
    }
    
    var hasDot: Bool = false
    var pendingNumberAfterDot: Bool = false
    
    var accumulator: Double?
    
    var pendingOperation: PendingOperation?
    
    var operations :[String: Operation] = [
        "E": Operation.constant(M_E),
        "*": Operation.operation{ $0 * $1 },
        "/": Operation.operation{ $1 == 0 ? 0 : $0/$1 },
        "+": Operation.operation{ $0 + $1 },
        "-": Operation.operation{ $0 - $1 },
        "=": Operation.equals,
        "C": Operation.clear,
        ".": Operation.dot
    ]

    enum Operation {
        case constant(Double)
        case operation((Double,Double) -> Double)
        case equals
        case clear
        case dot
    }
    
    struct PendingOperation {
        let function: (Double, Double)-> Double
        let first: Double
        
        func perform(with operand: Double) -> Double {
            return function(first, operand)
        }
    }

}

extension Calculator: CalculatorDelegate{
    
    
    func calculatorView(_ calculatorView: CalculatorView, didClickNumber number: String) {
        let size = calculatorView.resultText?.count ?? 0
        if size < 16 {
            calculatorView.resultText = (calculatorView.resultText ?? "") + number
            let calcText = calculatorView.resultText!
            let value: Double? = Double(calcText)
            self.accumulator = value
            if pendingNumberAfterDot == true { pendingNumberAfterDot = false}
        }
    }
    
    func calculatorView(_ calculatorView: CalculatorView, didClickOperator operation: String) {
        if let op = self.operations[operation] {
            switch op {
            case .clear:
                accumulator = nil
                calculatorView.resultText = ""
                
            case .dot:
                if !hasDot {
                    calculatorView.resultText = (calculatorView.resultText ?? "") + "."
                    hasDot = true
                    pendingNumberAfterDot = true
                }
                
            case .equals:
                if pendingOperation != nil && accumulator != nil && pendingNumberAfterDot == false {
                    accumulator = pendingOperation!.perform(with: accumulator!)
                    pendingOperation = nil
                    
                    let isDouble = accumulator!.truncatingRemainder(dividingBy: 1) != 0
                    var result = "\(accumulator!)"
                    
                    let size: Int = result.count
                    
                    if !isDouble {
                        result.removeLast()
                        result.removeLast()
                    }
                    
                    if size >= 20 {
                        result = accumulator!.scientificStyle
                    }
                    
                    calculatorView.resultText = result
                }
            
            case .constant(let value):
                self.accumulator = value
                calculatorView.resultText = "\(accumulator!)"
            
            case .operation(let function):
                if let accum = accumulator, pendingNumberAfterDot == false {
                    pendingOperation = PendingOperation(function: function, first: accum)
                    accumulator = nil
                    calculatorView.resultText = ""
                }
            }
        }
    }
}


protocol CalculatorDelegate {
    
    func calculatorView(_ calculatorView: CalculatorView, didClickNumber number: String)
    
    func calculatorView(_ calculatorView: CalculatorView, didClickOperator operation: String)

}

class CalculatorView: UIView {
    
    var resultText: String? {
        get {
            return resultLabel?.text
        } set {
            resultLabel?.text = newValue
        }
    }
    
    var delegate: CalculatorDelegate?
    
    var resultLabel: PaddingLabel!
    
    // 10 buttons
    var numberButtons: [UIButton]!
    
    // 8 action buttons
    var actionButtons: [UIButton]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        backgroundColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1)
        
        let spacing: CGFloat = 6
        
        resultLabel = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5))
        resultLabel.font = SystemSettings.notePadFont
        resultLabel.backgroundColor = .white
        resultLabel.layer.cornerRadius = 2
        resultLabel.layer.borderWidth = 1
        resultLabel.layer.borderColor = UIColor.black.cgColor
        resultLabel.textAlignment = .right
        
        numberButtons = []
        setNumbers()
        
        actionButtons = []
        setupOperators()
        
        // Create parent stack
        let parentStack = UIStackView()
        parentStack.axis = .vertical
        parentStack.spacing = spacing
        
        parentStack.addArrangedSubview(resultLabel)
        
        // create buttons holder
        let buttonsHolder = UIStackView()
        buttonsHolder.axis = .horizontal
        buttonsHolder.spacing = spacing
        
        parentStack.addArrangedSubview(buttonsHolder)
        
        // add constraints to [button holder]
        buttonsHolder.heightAnchor.constraint(equalTo:  resultLabel.heightAnchor, multiplier: 5.5).isActive = true

        // create left stack
        let leftStackView = UIStackView()
        leftStackView.axis = .vertical
        leftStackView.distribution = .fillEqually
        leftStackView.spacing = spacing
        
        // create right stack
        let rightStackView = UIStackView()
        rightStackView.axis = .vertical
        rightStackView.spacing = spacing
        
        // added [left] and [right] stack to [buttons holder]
        buttonsHolder.addArrangedSubview(leftStackView)
        buttonsHolder.addArrangedSubview(rightStackView)
        
        leftStackView.widthAnchor.constraint(equalTo: rightStackView.widthAnchor, multiplier: 3.0).isActive = true

        // setup [left] stack arragned subviews
        let topLeftStackView = UIStackView(arrangedSubviews: [actionButtons[0], actionButtons[1], actionButtons[2]]) // button C, E, =
        topLeftStackView.axis = .horizontal
        topLeftStackView.distribution = .fillEqually
        topLeftStackView.spacing = spacing
        leftStackView.addArrangedSubview(topLeftStackView)
        for i in (0...2).reversed(){
            
            // c = current
            let c = i * 3
            let tempStack = UIStackView(arrangedSubviews: [numberButtons[c+1], numberButtons[c+2], numberButtons[c+3]]) // button 7, 8, 9
            tempStack.spacing = spacing
            tempStack.axis = .horizontal
            tempStack.distribution = .fillEqually
            leftStackView.addArrangedSubview(tempStack)
        }
        
        
        let bottomLeftStackView = UIStackView(arrangedSubviews: [numberButtons[0], actionButtons[7]]) // button 0, dot
        
        // add width constraint
        numberButtons[0].widthAnchor.constraint(equalTo: actionButtons[7].widthAnchor, multiplier: 2.0).isActive = true
        
        bottomLeftStackView.axis = .horizontal
        bottomLeftStackView.spacing = spacing
        leftStackView.addArrangedSubview(bottomLeftStackView)
        
        // setup [right] stack arragned subviews
        rightStackView.addArrangedSubview(actionButtons[3])
        rightStackView.addArrangedSubview(actionButtons[4])
        rightStackView.addArrangedSubview(actionButtons[5])
        rightStackView.addArrangedSubview(actionButtons[6])

        // add constraints
        actionButtons[4].heightAnchor.constraint(equalTo: actionButtons[3].heightAnchor).isActive = true
        actionButtons[5].heightAnchor.constraint(equalTo: actionButtons[3].heightAnchor).isActive = true
        actionButtons[6].heightAnchor.constraint(equalTo: actionButtons[3].heightAnchor, multiplier: 2.0).isActive = true

        addSubview(parentStack)
        parentStack.translatesAutoresizingMaskIntoConstraints = false
        parentStack.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        parentStack.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        parentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        parentStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    }
    
    
    func setNumbers() {
        numberButtons.removeAll()
        for i in 0...9 {
            let button = genericButton()
            button.setTitle("\(i)", for: [])
            button.addTarget(self, action: #selector(handleNumberic(sender:)), for: .touchUpInside)
            numberButtons.append(button)
        }
    }
    
    func setupOperators() {
        actionButtons.removeAll()
        
        let operations = ["C", // 0
                          "E", // 1
                          "=", // 2
                          "*", // 3
                          "/", // 4
                          "-", // 5
                          "+", // 6
                          "."] // 7
        
        for operation in operations {
            let button = genericButton()
            button.setTitle(operation, for: [])
            button.addTarget(self, action: #selector(handleOperation(sender:)), for: .touchUpInside)
            actionButtons.append(button)
        }
    }
    
    
    @objc func handleNumberic(sender: UIButton) {
        delegate?.calculatorView(self, didClickNumber: (sender.currentTitle)!)
    }
    
    @objc func handleOperation(sender: UIButton){
        delegate?.calculatorView(self, didClickOperator: (sender.currentTitle!))
    }
    
    func genericButton() -> UIButton {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.setBackgroundImage(UIImage(color: .white), for: [])
        button.setBackgroundImage(UIImage(color: .black), for: .highlighted)
        
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 0
        button.titleLabel?.font = SystemSettings.notePadFont
        
        return button
    }
}

class PaddingLabel: UILabel {
    
    let padding: UIEdgeInsets
    
    // Create a new PaddingLabel instance programatically with the desired insets
    init(padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)) {
        self.padding = padding
        super.init(frame: CGRect.zero)
    }
    
    // Create a new PaddingLabel instance programaticlly with default insects
    override init(frame: CGRect) {
        padding = UIEdgeInsets.zero // set desired insects value according to your needs
        super.init(frame: frame)
    }
    
    // Create a new PaddingLabel instance from Storyboard with default insets
    required init?(coder aDecoder: NSCoder) {
        padding = UIEdgeInsets.zero // set desired insects value according to your needs
        super.init(coder: aDecoder)
    }
    
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, padding))
    }
    
    // Override `intrinsicContentSize` property for Auto layout code
    override var intrinsicContentSize: CGSize{
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + padding.left + padding.right
        let height = superContentSize.height + padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
    
    // Override `sizeThatFits(_:)` method for Springs & structs code
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + padding.left + padding.right
        let height = superSizeThatFits.height + padding.top + padding.bottom
        return CGSize(width: width, height: height)
    }
}

extension Double{
    struct Number {
        static var formatter = NumberFormatter()
    }
    
    var scientificStyle: String {
        Number.formatter.numberStyle = .scientific
        Number.formatter.positiveFormat = "0.###E+0"
        Number.formatter.exponentSymbol = "e"
        return Number.formatter.string(from: NSNumber(value: self)) ?? description
    }
}
