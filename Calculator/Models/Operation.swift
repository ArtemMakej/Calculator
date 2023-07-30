//
//  Operation.swift
//  Calculator
//
//  Created by Artem Makei on 23/07/2023.
//

import Foundation

/// Перечисление (основные математические операции и цифры)
enum Operation {
    case clear
    case percent
    case divide
    case multiply
    case substract
    case add
    case equal
    case comma
    case digit(Double)
    
    init?(text: String) {
        switch text {
        case "AC":
            self = .clear
        case "%":
            self = .percent
        case "/":
            self = .divide
        case "*":
            self = .multiply
        case "-":
            self = .substract
        case "+":
            self = .add
        case "=":
            self = .equal
        case ",":
            self = .comma
        case text where Double(text) != nil:
            self = .digit(Double(text)!)
        default:
            return nil
        }
    }
}
