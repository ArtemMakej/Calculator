//
//  ViewController.swift
//  Calculator
//
//  Created by Artem Makei on 06/07/2023.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet var functionalButtons: [UIButton]!
    @IBOutlet var digitsButtons: [UIButton]!
    
    // MARK: - Properties
    
    private var result: Double = 0
    private var currentDigit = "0"
    private var shouldClearCurrentDigit = false
    private var currentMathOperation: Operation?
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let allButtons = digitsButtons + functionalButtons
        for digitButton in digitsButtons {
            let customButton = digitButton as? CustomButton
            customButton?.isDigitButton = true
        }
        for button in allButtons {
            button.layer.cornerRadius = 35
            button.layer.masksToBounds = true
        }
        bindButtons(buttonsArray: allButtons)
        resultsLabel.text = formatNumber(result)
        feedbackGenerator.prepare()
    }
    // функция округляет края кнопок
    func roundCorners(buttonsArray: [UIButton], cornerRadius: CGFloat) {
        for button in buttonsArray {
            button.layer.cornerRadius = cornerRadius
        }
    }
    // функция добавляет обработку нажатия кнопкам
    func bindButtons(buttonsArray: [UIButton]) {
        for button in buttonsArray {
            button.addTarget(self,
                             action: #selector(buttonAction),
                             for: .touchUpInside)
        }
    }
    @objc func buttonAction(sender: UIButton) {
        feedbackGenerator.impactOccurred()
        let operationOptional = Operation(text: sender.titleLabel?.text ?? "")
        
        guard let operation = operationOptional else {
            fatalError("Couldn't init operation from button title")
        }
        switchOperation(operation)
    }
    
    func switchOperation(_ operation: Operation) {
        switch operation {
            
            // обработка кнопки "АС"
        case .clear:
            result = 0
            currentDigit = "0"
            resultsLabel.text = formatNumber(result)
            shouldClearCurrentDigit = false
            
            // обработка процентов
        case .percent:
            
            guard let currentNumber = Double(currentDigit) else { return }
            let percentValue = currentNumber / 100.0
            result = percentValue
            currentDigit = String(percentValue)
            resultsLabel.text = formatNumber(result)
            
            // обработка деления, умножения, сложения и вычитания
        case .divide, .multiply, .substract, .add:
            
            if currentMathOperation != nil {
                calculatorResult()
            }
            currentMathOperation = operation
            guard let currentNumber = Double(currentDigit) else { return }
            result = currentNumber
            currentDigit = "0"
            
            // обработка равно
        case .equal:
            calculatorResult()
            currentMathOperation = nil
            shouldClearCurrentDigit = true
            
            // Обработка запятой (десятичного разделителя)
        case .comma:
            if !currentDigit.contains(".") {
                currentDigit += "."
                resultsLabel.text = currentDigit
            }
            
            //обработка цифр
        case let .digit(number):
            
            if shouldClearCurrentDigit {
                currentDigit = ""
                shouldClearCurrentDigit = false
            }
            
            var digitsText = currentDigit + String(Int(number))
            if digitsText.hasPrefix("0") {
                digitsText.remove(at: digitsText.startIndex)
            }
            
            currentDigit = digitsText
            resultsLabel.text = formatNumber(Double(digitsText) ?? 0)
        }
    }
    
    func mathOperation() {
        guard let currentNumber = Double(currentDigit) else {return}
        switch currentMathOperation {
        case .divide:
            if currentNumber == 0 {
                result = 0
                let alert = UIAlertController(title: String.zeroDivisionWarningTitle, message: "Будьте внимательны 🤓", preferredStyle: .alert)
                let okActtion = UIAlertAction(title: "ok", style: .default, handler: nil)
                alert.addAction(okActtion)
                present(alert, animated: true, completion: nil)
            } else {
                result = result / currentNumber
            }
        case .multiply:
            result  = result * currentNumber
        case .substract:
            result  = result - currentNumber
        case .add:
            result  = result + currentNumber
        default:
            return
        }
    }
    
    func calculatorResult() {
        mathOperation()
        resultsLabel.text = formatNumber(result)
        currentDigit = "0"
    }
    
    func formatNumber(_ number: Double) -> String {
        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
        
    }
}

private extension String {
    
    static let zeroDivisionWarningTitle = "На 0 делить нельзя!"
}
