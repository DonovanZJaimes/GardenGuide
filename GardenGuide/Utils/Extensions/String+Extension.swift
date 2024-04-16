//
//  String+Extension.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 13/04/24.
//

import Foundation
extension String {
    init?(passwordSafeString: String) {
        guard passwordSafeString.rangeOfCharacter(from: .uppercaseLetters) != nil && passwordSafeString.rangeOfCharacter(from: .lowercaseLetters) != nil && passwordSafeString.rangeOfCharacter(from: .punctuationCharacters) != nil && passwordSafeString.rangeOfCharacter(from: .decimalDigits) != nil else {
            return nil
        }
        self = passwordSafeString
        
    }
    
    var isValidEmail: Bool {
        let firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegex = firstpart + "@" + serverpart + "[A-Za-z]{2,6}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    

}

