//
//  String+ExtensionTests.swift
//  GardenGuideTests
//
//  Created by Donovan Z. Jaimes on 17/04/24.
//

import XCTest
@testable import GardenGuide
//@testable import FirebaseCore

final class String_ExtensionTests: XCTestCase {
    var uppercaseLetters = CharacterSet.uppercaseLetters.getCharacters()
    var lowercaseLetters = CharacterSet.lowercaseLetters.getCharacters()
    var punctuationCharacters = CharacterSet.punctuationCharacters.getCharacters()
    var decimalDigits = CharacterSet.decimalDigits.getCharacters()
    
    private var possiblePasswords = [String]()
    
    override func setUpWithError() throws {
    
    }

    override func tearDownWithError() throws {
        possiblePasswords = []
    }
    
    func test_passwordSafeString_checkIfItIsAGoodPassword() {
        //Arange
        var password: String = ""
        
        //Act
        for _ in 0...10 {
            password = uppercaseLetters.randomElement()! + lowercaseLetters.randomElement()! + punctuationCharacters.randomElement()! + decimalDigits.randomElement()!
            possiblePasswords.append(password)
            
        }
        
        //Assert
        possiblePasswords.forEach { password in
            XCTAssertNotNil(String(passwordSafeString: password), "The password does not meet the required guidelines")
        }
    }
    
    func test_passwordSafeString_checkIfItIsABadPassword() {
        //Arange
        var password: String = ""
        
        //Act
        for _ in 0...10 {
            let random = Int.random(in: 0...3)
            password = uppercaseLetters.randomElement()! + lowercaseLetters.randomElement()! + punctuationCharacters.randomElement()! + decimalDigits.randomElement()!
            let index: String.Index = password.index(password.startIndex, offsetBy: random)
            password.remove(at: index)
            possiblePasswords.append(password)
            
        }
        
        //Assert
        possiblePasswords.forEach { password in
            XCTAssertNil(String(passwordSafeString: password),"The password does not meet the required guidelines" )
        }
        
        
    }

    

}
