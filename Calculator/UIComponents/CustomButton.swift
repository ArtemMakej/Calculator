//
//  CustomButton.swift
//  Calculator
//
//  Created by Artem Makei on 23/07/2023.
//

import UIKit

final class CustomButton: UIButton {
    
    var isDigitButton = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard isDigitButton else { return }
        backgroundColor = .lightGray
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard isDigitButton else { return }
        backgroundColor = nil
    }
}
