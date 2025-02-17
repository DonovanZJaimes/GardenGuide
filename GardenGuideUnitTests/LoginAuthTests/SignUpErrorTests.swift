//
//  SignUpErrorTests.swift
//  GardenGuideUnitTests
//
//  Created by Donovan Z. Jaimes on 14/02/25.
//

import XCTest
@testable import GardenGuide

final class SignUpErrorTests: XCTestCase {

    func test_SignUpError_DetermineNumberOfCases() throws {
        //Arrange
        let cases: Int = 2 // The SignUpError has 2 cases
        //Act
        //Assert
        XCTAssertEqual(SignUpError.allCases.count, cases, "The number of cases is incorrect")
        
    }
    
    func test_SignUpError_DetermineTehRawValueOfCases() {
        //Arrange
        let signUpErrorPassword = "invalidPassword"
        let signUpErrorEmail = "invalidEmail"
        
        //Act
        //Assert
        XCTAssertEqual(signUpErrorEmail, SignUpError.invalidEmail.rawValue, "The case name is incorrect")
        XCTAssertEqual(signUpErrorPassword, SignUpError.invalidPassword.rawValue, "The case name is incorrect")
    }
    
    func test_SignUpError_DetermineTheLocalizedErrorOfCases() {
        //Arrange
        let signUpErrorPassword = "The password must have at least one lowercase letter, one uppercase letter, one number, and one special character"
        let signUpErrorEmail = "The email address is invalid"
        
        //Act
        //Assert
        XCTAssertEqual(signUpErrorEmail, SignUpError.invalidEmail.localizedDescription!, "The case localizedDescription is incorrect")
        XCTAssertEqual(signUpErrorPassword, SignUpError.invalidPassword.localizedDescription!, "The case localizedDescription is incorrect")    }


}
