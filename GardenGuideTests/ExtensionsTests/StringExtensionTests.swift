//
//  StringExtensionTests.swift
//  GardenGuideTests
//
//  Created by Donovan Z. Jaimes on 18/04/24.
//

import XCTest
@testable import GardenGuide

final class StringExtensionTests: XCTestCase {
    var possiblePasswords = [String]()
    var possibleEmails = [String]()
    
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        possiblePasswords = []
        possibleEmails = []
    }


    func test_passwordSafeString_checkIfItIsAGoodPassword() {
        //Arrange
        possiblePasswords = ["𝖸ӫ⁃᧒", "Ϯ𝛽𑬈९", "Ӎά”𑙖", "𝜰ế︰𝟘", "Ꮡᴎ!٩", "Ґꞙ࠰൮", "É𝒔𑗏𝟮", "𝐍ß⸆៥", "𖹉ӻ︕𑜰", "𝙂ċ⦑၇", "Ꞙṫ⁅𝟸"]
        //Act
        
        //Assert
        possiblePasswords.forEach { password in
            XCTAssertNotNil(String(passwordSafeString: password), "The password does not meet the required guidelines")
        }
        
    }
    
    func test_passwordSafeString_checkIfItIsABadPassword() {
        //Arrange
        possiblePasswords = ["Ƿ𝛼᳀", "𝑫ű︹", "Ნ꣸꧐", "Ἀ⹘𞥗", "Ꮷг𞋷", "𝒰ᴧ﹞", "Ẫ𝝵⹇", "G⁍꧐", "ᏽ⟧൨", "Ⰺⱃ𑜲", "Çự𑥖"]
      
        //Assert
        possiblePasswords.forEach { password in
            XCTAssertNil(String(passwordSafeString: password),"The password does not meet the required guidelines" )
        }
        
    }

    func test_isValidEmail_checkIfItIsAGodPassword() {
        //Arrange
        possibleEmails = ["lmn99630@romog.com", "kre38450@romog.com", "clh80909@vogco.com", "mzw45166@ilebi.com", "mkk06806@vogco.com", "slu61127@romog.com", "gdd14717@ilebi.com", "vsu06094@ilebi.com", "lix18137@vogco.com", "evq93374@romog.com", "gam88838@ilebi.com"]
        //Act
        
        //Assert
        possibleEmails.forEach { email in
            XCTAssertTrue(email.isValidEmail, "The email does not meet the required guidelines")
        }
        
    }
    
    func test_isValidEmail_checkIfItIsAbadPassword() {
        //Arrange
        possibleEmails = ["@ilebi.com", "@romog.com", "clh80909vogco.com", "mzw45166ilebi.com", "mkk06806@.com", "slu61127@.com", "gdd14717@ilebicom", "vsu06094@ilebicom", "lix18137@vogco.", "evq93374@romog.", "gam88838@ilebi.com345&"]
        
        //Assert
        possibleEmails.forEach { email in
            XCTAssertFalse(email.isValidEmail, "The email does not meet the required guidelines")
        }
    }

}





/*
 
 
 
 /*var uppercaseLetters = CharacterSet.uppercaseLetters.getCharacters()
 var lowercaseLetters = CharacterSet.lowercaseLetters.getCharacters()
 var punctuationCharacters = CharacterSet.punctuationCharacters.getCharacters()
 var decimalDigits = CharacterSet.decimalDigits.getCharacters()*/
 /*
 private var possiblePasswords = [String]()
 
 override func setUpWithError() throws {
 
 }

 override func tearDownWithError() throws {
     possiblePasswords = []
 }
 
 func test_passwordSafeString_checkIfItIsAGoodPassword() {
     /*//Arange
     var password: String = ""
     
     //Act
     for _ in 0...10 {
         password = uppercaseLetters.randomElement()! + lowercaseLetters.randomElement()! + punctuationCharacters.randomElement()! + decimalDigits.randomElement()!
         possiblePasswords.append(password)
         
     }
     
     //Assert
     possiblePasswords.forEach { password in
         XCTAssertNotNil(String(passwordSafeString: password), "The password does not meet the required guidelines")
     }*/
     
     XCTAssertTrue(true)
 }
 
 func test_passwordSafeString_checkIfItIsABadPassword() {
     /*//Arange
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
     
      */
     XCTAssertTrue(true)
 }

 */

 
 
 
 
 
 **/
