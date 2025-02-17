//
//  NetworkErrorFirebaseTests.swift
//  GardenGuideUnitTests
//
//  Created by Donovan Z. Jaimes on 14/02/25.
//

import XCTest
@testable import GardenGuide

final class NetworkErrorFirebaseTests: XCTestCase {

    func test_NetworkErrorFirebase_DetermineNumberOfCases() throws {
        //Arrange
        let cases: Int = 7 // The NetworkErrorFirebase has 7 cases
        //Act
        //Assert
        XCTAssertEqual(NetworkErrorFirebase.allCases.count, cases, "The number of cases is incorrect")
        
    }
    
    func test_NetworkErrorFirebase_DetermineTehRawValueOfCases() {
        //Arrange
        let errorEmailAlredyInUse = "ErrorEmailAlredyInUse"
        let errorWeakPassword = "ErrorWeakPassword"
        let errorMissingEmail = "ErrorMissingEmail"
        let errorInvalidEmail = "ErrorInvalidEmail"
        let errorInvalidPassword = "ErrorInvalidPassword"
        let errorWrongPassword = "ErrorWrongPassword"
        let errorGeneric = "ErrorGeneric"
        
        //Act
        //Assert
        XCTAssertEqual(errorEmailAlredyInUse, NetworkErrorFirebase.ErrorEmailAlredyInUse.rawValue, "The case name is incorrect")
        XCTAssertEqual(errorWeakPassword, NetworkErrorFirebase.ErrorWeakPassword.rawValue, "The case name is incorrect")
        XCTAssertEqual(errorMissingEmail, NetworkErrorFirebase.ErrorMissingEmail.rawValue, "The case name is incorrect")
        XCTAssertEqual(errorInvalidEmail, NetworkErrorFirebase.ErrorInvalidEmail.rawValue, "The case name is incorrect")
        XCTAssertEqual(errorInvalidPassword, NetworkErrorFirebase.ErrorInvalidPassword.rawValue, "The case name is incorrect")
        XCTAssertEqual(errorWrongPassword, NetworkErrorFirebase.ErrorWrongPassword.rawValue, "The case name is incorrect")
        XCTAssertEqual(errorGeneric, NetworkErrorFirebase.ErrorGeneric.rawValue, "The case name is incorrect")
    }
    
    func test_NetworkErrorFirebase_DetermineTheLocalizedErrorOfCases() {
        //Arrange
        //Act
        //Assert
        XCTAssertNotNil(NetworkErrorFirebase.ErrorEmailAlredyInUse.errorDescription!, "The case errorDescription is incorrect" )
        XCTAssertNotNil(NetworkErrorFirebase.ErrorWeakPassword.errorDescription!, "The case errorDescription is incorrect" )
        XCTAssertNotNil(NetworkErrorFirebase.ErrorMissingEmail.errorDescription!, "The case errorDescription is incorrect" )
        XCTAssertNotNil(NetworkErrorFirebase.ErrorInvalidEmail.errorDescription!, "The case errorDescription is incorrect" )
        XCTAssertNotNil(NetworkErrorFirebase.ErrorInvalidPassword.errorDescription!, "The case errorDescription is incorrect" )
        XCTAssertNotNil(NetworkErrorFirebase.ErrorWrongPassword.errorDescription!, "The case errorDescription is incorrect" )
        XCTAssertNotNil(NetworkErrorFirebase.ErrorGeneric.errorDescription!, "The case errorDescription is incorrect" )
        
    }
    func test_NetworkErrorFirebase_DetermineTheErrorCodeOfCases() {
        //Arrange
        let errorEmailAlredyInUseCode = "17007"
        let errorWeakPasswordCode = "17026"
        let errorMissingEmailCode = "17034"
        let errorInvalidEmailCode = "17008"
        let errorInvalidPasswordCode = "17004"
        let errorWrongPasswordCode = "17009"
        let errorGenericCode = "170"
        //Act
        let errorEmailAlredyInUse = NetworkErrorFirebase.ErrorEmailAlredyInUse
        let errorWeakPassword = NetworkErrorFirebase.ErrorWeakPassword
        let errorMissingEmail = NetworkErrorFirebase.ErrorMissingEmail
        let errorInvalidEmail = NetworkErrorFirebase.ErrorInvalidEmail
        let errorInvalidPassword = NetworkErrorFirebase.ErrorInvalidPassword
        let errorWrongPassword = NetworkErrorFirebase.ErrorWrongPassword
        let errorGeneric = NetworkErrorFirebase.ErrorGeneric
        
        //Assert
        XCTAssertEqual(errorEmailAlredyInUseCode, errorEmailAlredyInUse.errorCode, "The error code is wrong")
        XCTAssertEqual(errorWeakPasswordCode , errorWeakPassword.errorCode, "The error code is wrong")
        XCTAssertEqual(errorMissingEmailCode , errorMissingEmail.errorCode, "The error code is wrong")
        XCTAssertEqual(errorInvalidEmailCode , errorInvalidEmail.errorCode, "The error code is wrong")
        XCTAssertEqual(errorInvalidPasswordCode , errorInvalidPassword.errorCode, "The error code is wrong")
        XCTAssertEqual(errorWrongPasswordCode , errorWrongPassword.errorCode, "The error code is wrong")
        XCTAssertEqual(errorGenericCode , errorGeneric.errorCode, "The error code is wrong")
        
    }
    
    func test_analyzeError_WhenItReceiveAnErrorText() {
        //Arrange
        let possibleErrorMessages: [String] = ["Error Domain=FIRAuthErrorDomain Code=17007 The email address is already in use by another account.", "Code=17026 The password must be 6 characters long or more. UserInfo={FIRAuthErrorUserInfoNameKey=ERROR_WEAK_PASSWORD, NSLocalizedFailureReason=Missing Password,", "Error Domain=FIRAuthErrorDomain Code=17034 ", "17008 The email address is badly formatted. UserInfo={NSLocalizedDescription=", "Error Domain=FIRAuthErrorDomain Code=17004", "Error Domain=FIRAuthErrorDomain Code=17009 The password is invalid or the user does not have a password. UserInfo={NSLocalizedDescription", "Error Domain=FIRAuthErrorDomain Code=2345"]
        let errorMessages: [String] = [NetworkErrorFirebase.ErrorEmailAlredyInUse.errorDescription!, NetworkErrorFirebase.ErrorWeakPassword.errorDescription!, NetworkErrorFirebase.ErrorMissingEmail.errorDescription!, NetworkErrorFirebase.ErrorInvalidEmail.errorDescription!, NetworkErrorFirebase.ErrorInvalidPassword.errorDescription!, NetworkErrorFirebase.ErrorWrongPassword.errorDescription!, NetworkErrorFirebase.ErrorGeneric.errorDescription!]
        
        //Act
        let errorGeneric = NetworkErrorFirebase.ErrorGeneric
        print(errorMessages)
        //Assert
        for index in 0..<possibleErrorMessages.count {
            
            XCTAssertEqual(errorGeneric.analyzeError(possibleErrorMessages[index]), errorMessages[index], "The error code is invalid")
        }
        
    }
    
    
}
