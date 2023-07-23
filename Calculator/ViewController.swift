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
    
    private var result: Double = 0 // результат вычислений
    private var currentDigit = "0" // используется в калькуляторе для отслеживания текущей цифры
    private var shouldClearCurrentDigit = false // читать (1)
    private var currentMathOperation: Operation? //используется для отслеживания текущей математической операции
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium) // создаем экземпляр класса UIImpactFeedbackGenerator - отвечает за тактильную обратную связь // класс создает физическую обратную связь с пользователем через тактильные механизмы (вибрацию)
    
    // добавлено новое свойство numberFormatter, которое отвечает за форматирования чисел
    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter() // инициализировали класс
        formatter.numberStyle = .decimal // свойство numberStyle в .decimal указывает, что число должно быть отформатировано в десятичном стиле.
        return formatter
    }() // скобки ()  позволяют вызвать клоужер
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let allButtons = digitsButtons + functionalButtons
        // инициа
        for digitButton in digitsButtons {
            let customButton = digitButton as? CustomButton //приведение типа (as?) для переменной digitButton к типу CustomButton.
            customButton?.isDigitButton = true // ставим флаг на обработку digitButton, чтобы при тапе срабатывала подцветка только на них (все кнопки через сториборд привязаны к классу CustomButton)
        }
        // Установить округление углов для каждой кнопки
        // создадим массив
        for button in allButtons {
            button.layer.cornerRadius = 35
            button.layer.masksToBounds = true // используется для обрезки кнопок, чтобы они соответствовали закругленной форме, установленной layer.cornerRadius
        }
        bindButtons(buttonsArray: allButtons) // вызов bindButtons
        resultsLabel.text = formatNumber(result) // result форматируется с использованием numberFormatter и отображается в resultsLabel с помощью метода formatNumber(_:)
        feedbackGenerator.prepare() //Метод prepare() используется для подготовки вызова обратной связи тактильного отклика
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
    
    //Функция buttonAction является обработчиком события нажатия на кнопку (@objc указывает, что вы взаимодействуете с фреймворками, написанными на Objective-C)
    @objc func buttonAction(sender: UIButton) { // Параметр sender представляет кнопку, на которую было произведено нажатие
        feedbackGenerator.impactOccurred() //Метод вызывает генерацию тактильной обратной связи, чтобы передать пользователю физическое ощущение, связанное с нажатием кнопки
        let operationOptional = Operation(text: sender.titleLabel?.text ?? "") //создаем экземпляр enum Operation, используя значение текста кнопки, на которую было произведено нажатие
        
        guard let operation = operationOptional else {
            fatalError("Couldn't init operation from button title")
        }
        
        switch operation {
            
            // обработка кнопки "АС"
        case .clear:
            result = 0 //result устанавливается в 0, чтобы сбросить текущий результат вычислений
            currentDigit = "0" //currentDigit устанавливается в "0", чтобы сбросить текущую цифру
            resultsLabel.text = formatNumber(result) // вызывая метод formatNumber(result) форматирует число result и устанавливает его как текст для resultsLabel.
            shouldClearCurrentDigit = false // false, чтобы указать, что текущая цифра не должна быть очищена.
            
            // обработка процентов
        case .percent:
            
            guard let currentNumber = Double(currentDigit) else { return } // Эта строка пытается преобразовать текущую цифру (currentDigit) в число типа Double
            let percentValue = currentNumber / 100.0 //Здесь вычисляется процентное значение от текущей цифры
            result = percentValue
            currentDigit = String(percentValue)
            resultsLabel.text = formatNumber(result) //Обновляется текст в resultsLabel с помощью метода formatNumber, который форматирует число result
            
            // обработка деления, умножения, сложения и вычитания
        case .divide, .multiply, .substract, .add:
            
            if currentMathOperation != nil { // происходит проверка, существует ли уже текущая математическая операция (currentMathOperation). Если да, то вызывается функция calculatorResult(), которая выполняет расчет результата
                calculatorResult()
            }
            currentMathOperation = operation
            guard let currentNumber = Double(currentDigit) else { return } //Эта строка пытается преобразовать текущую цифру (currentDigit) в число типа Double
            result = currentNumber
            currentDigit = "0" //Текущая цифра (currentDigit) устанавливается в "0", чтобы пользователь мог ввести новую цифру.
            
            // обработка равно
        case .equal:
            calculatorResult() //Здесь вызывается функция calculatorResult()
            currentMathOperation = nil //Значение nil присваивается переменной currentMathOperation, чтобы указать, что текущая математическая операция больше не существует
            shouldClearCurrentDigit = true // Значение true присваивается переменной shouldClearCurrentDigit, чтобы указать, что текущая цифра должна быть очищена
            
            // Обработка запятой (десятичного разделителя)
        case .comma:
            if !currentDigit.contains(".") { //выполняется проверка, не содержит ли текущая цифра уже десятичный разделитель (точку)
                currentDigit += "." // Если текущая цифра не содержит дес. разделителя, то он добавляется
                resultsLabel.text = currentDigit //устанавливая значение текущей цифры
            }
            
            //обработка цифр
        case let .digit(number):
            
            if shouldClearCurrentDigit { // Здесь выполняется проверка флага shouldClearCurrentDigit,  если , true, то  текущая цифра может быть очищена
                currentDigit = "" //текущая цифра (currentDigit) устанавливается в пустую строку ("") для начала ввода новой цифры
                shouldClearCurrentDigit = false //false  указывает, что очистка не требуется перед добавлением новой цифры.
            }
            
            var digitsText = currentDigit + String(Int(number)) //Например, если currentDigit равно "1", а number равно 2, то digitsText будет содержать "12"
            if digitsText.hasPrefix("0") { // .hasPrefix("0") - метод, который проверят, начинается ли строка с указанной подстроки, в нашем случае "0"
                digitsText.remove(at: digitsText.startIndex)  //Метод remove(at:) удаляет символ по указанному индексу
            //startIndex - это свойство , которое представляет (индекс) 1-го символа в строке.
            }
            
            currentDigit = digitsText //Значение переменной currentDigit присваиватся значению digitsText
            resultsLabel.text = formatNumber(Double(digitsText) ?? 0) // В этой строке, digitsText преобразуется в Double, а затем форматируется с помощью метода formatNumber (форматирует число, убрая числа после запятой). Если digitsText не преобразована в число типа Double, оператор ?? (nil-coalescing operator) возвращает 0.
        }
    }
    //Функция calculatorResult() выполняет вычисление результата на основе текущей математической операции (currentMathOperation) и текущей цифры (currentDigit).
    
    func calculatorResult() {
        guard let currentNumber = Double(currentDigit) else {return} // Эта строка пытается преобразовать текущую цифру (currentDigit) в число типа Double
        
        //Далее функция выполняет операцию switch на основе значения currentMathOperation
        switch currentMathOperation {
        case .divide:
            if currentNumber == 0 {
                result = 0
            let alert = UIAlertController(title: "На 0 делить нельзя!", message: "Будьте внимательны 🤓", preferredStyle: .alert)
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

        
    resultsLabel.text = formatNumber(result) //result форматируется с использованием numberFormatter перед отображением в resultsLabel
        currentDigit = "0"
    }
    // создадим метод formatNumber(_:), который будет принимать число и форматировать  его с использованием numberFormatter, возвращая  стринг . Если форматирование не удалось, возвращается пустая строка.
    func formatNumber(_ number: Double) -> String {
        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
        
    }
}
