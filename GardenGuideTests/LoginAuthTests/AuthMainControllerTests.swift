//
//  AuthMainControllerTests.swift
//  GardenGuideTests
//
//  Created by Donovan Z. Jaimes on 21/04/24.
//

import XCTest
@testable import GardenGuide

@MainActor final class AuthMainControllerTests: XCTestCase {
    var sutDelegate: AuthMainViewControllerMock!
    var sut: AuthMainController!
    
    @MainActor override func setUpWithError() throws {
        sutDelegate = AuthMainViewControllerMock()
        sut = AuthMainController(delegate: sutDelegate)
    }

    @MainActor override func tearDownWithError() throws {
        sut = nil
        sutDelegate.IsTheAuthenticationSuccessful = nil
        sutDelegate = nil
    }


    func test_signUpAnonymously_CheckIfYouCanAuthenticateAnonymously() throws{ //3
        //Arrange
        sutDelegate.IsTheAuthenticationSuccessful = nil
        
        //Act
        sutDelegate.expectation = expectation(description: "loading")
        //Task{
            sut.signUpAnonymously()
        //}
        waitForExpectations(timeout: 2.1)
    
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("Don't have time to create an anonymous user")
            return
        }
        
        XCTAssertTrue(Authentication, "could not create an anonymous account")
    }
    
    
    //MARK: SignIn
    func test_signInWithEmail_withExistingEmailButNoPassword() { //1
        //Code=17009
        //Arrange
        let error = NetworkErrorFirebase.ErrorWrongPassword.errorDescription!
        let password: String = ""
        let email: String = "lpa26141@vogco.com"
        
        //Act
        sutDelegate.expectation = expectation(description: "ExistingEmailButNoPassword")
        //Task{
            sut.signInWithEmail(email, password: password)
        //}
        waitForExpectations(timeout: 3.1)
            
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("There was not enough time to verify the data ")
            return
        }
        
        XCTAssertFalse(Authentication, "There is a problem with the password or email sent")
        XCTAssertEqual(sutDelegate.error, error, "The error received does not match")
        
    }
    
    func test_signInWithEmail_withExistingEmailButIncorrectPassword() {
        //Code=17004
        //Arrange
        let error = NetworkErrorFirebase.ErrorInvalidPassword.errorDescription!
        let password: String = "4@d"
        let email: String = "lpa26141@vogco.com"
        
        //Act
        sutDelegate.expectation = expectation(description: "ExistingEmailButIncorrectPassword")
        //Task{
            sut.signInWithEmail(email, password: password)
        //}
        waitForExpectations(timeout: 3.2)
            
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("There was not enough time to verify the data ")
            return
        }
        
        XCTAssertFalse(Authentication, "There is a problem with the password or email sent")
        XCTAssertEqual(sutDelegate.error, error, "The error received does not match")
    }
    
    func test_signInWithEmail_withIncorrectEmailAndFullPassword() { //2
        //Code=17008
        //Arrange
        let error = NetworkErrorFirebase.ErrorInvalidEmail.errorDescription!
        let password: String = "4@dWert3Ade3"
        let email: String = "lpa26141@vogco."
        
        //Act
        sutDelegate.expectation = expectation(description: "IncorrectEmailAndFullPassword")
        //Task{
            sut.signInWithEmail(email, password: password)
       // }
        waitForExpectations(timeout: 4.0)
            
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("There was not enough time to verify the data ")
            return
        }
        
        XCTAssertFalse(Authentication, "There is a problem with the password or email sent")
        XCTAssertEqual(sutDelegate.error, error, "The error received does not match")
    }
    
    
    
    //MARK: SignUp
    func test_signUpWithEmail_withEmailAndSmallPassword() throws {
        //Code=17026
        //Arrange
        let error = NetworkErrorFirebase.ErrorWeakPassword.errorDescription!
        let password: String = "gF4@"
        let email: String = "gqc92362@fosiq.com"
        
        //Act
        sutDelegate.expectation = expectation(description: "loading Small Password ")
        //Task{
            sut.signUpWithEmail(email, password: password)
        //}
        waitForExpectations(timeout: 3.1)
            
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("There was not enough time to verify the data ")
            return
        }
        
        XCTAssertFalse(Authentication, "There is a problem with the password or email sent")
        XCTAssertEqual(sutDelegate.error, error, "The error received does not match")
        
    }
    
    func test_signUpWithEmail_withoutEmailAndPassword() throws {
        //Code=17026
        //Arrange
        let error = NetworkErrorFirebase.ErrorWeakPassword.errorDescription!
        let password: String = ""
        let email: String = ""
        
        //Act
        sutDelegate.expectation = expectation(description: "withoutEmailAndPassword")
        //Task{
            sut.signUpWithEmail(email, password: password)
        //}
        waitForExpectations(timeout: 3.1)
            
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("There was not enough time to verify the data ")
            return
        }
        
        XCTAssertFalse(Authentication, "There is a problem with the password or email sent")
        XCTAssertEqual(sutDelegate.error, error, "The error received does not match")
        
    }
    
    func test_signUpWithEmail_withAuthenticatedEmailAndWrongPassword() throws { //1
        //Code=17007
        
        //Arrange
        let error = NetworkErrorFirebase.ErrorEmailAlredyInUse.errorDescription!
        let password: String = "4#Adui"
        let email: String = "lpa26141@vogco.com"
        
        //Act
        sutDelegate.expectation = expectation(description: "withAuthenticatedEmailAndWrongPassword")
        //Task{
            sut.signUpWithEmail(email, password: password)
        //}
        waitForExpectations(timeout: 3.5)
            
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("There was not enough time to verify the data ")
            return
        }
        
        XCTAssertFalse(Authentication, "There is a problem with the password or email sent")
        XCTAssertEqual(sutDelegate.error, error, "The error received does not match")
        
    }
    
    func test_signUpWithEmail_withoutEmailAndWithPassword() throws {
        //Code=17034
        
        //Arrange
        let error = NetworkErrorFirebase.ErrorMissingEmail.errorDescription!
        let password: String = "4#Adui"
        let email: String = ""
        
        //Act
        sutDelegate.expectation = expectation(description: "withoutEmailAndWithPassword")
        //Task{
            sut.signUpWithEmail(email, password: password)
        //}
        waitForExpectations(timeout: 3.5)
            
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("There was not enough time to verify the data ")
            return
        }
        
        XCTAssertFalse(Authentication, "There is a problem with the password or email sent")
        XCTAssertEqual(sutDelegate.error, error, "The error received does not match")
        
    }
    
    func test_signUpWithEmail_withBadEmailAndGoodPassword() throws {
        //Code=17008
        
        //Arrange
        let error = NetworkErrorFirebase.ErrorInvalidEmail.errorDescription!
        let password: String = "4#Adui"
        let email: String = "asdf5@hjh."
        
        //Act
        sutDelegate.expectation = expectation(description: "withBadEmailAndGoodPassword")
        //Task{
            sut.signUpWithEmail(email, password: password)
        //}
        waitForExpectations(timeout: 4.5)
            
        //Assert
        guard let Authentication = sutDelegate.IsTheAuthenticationSuccessful else {
            XCTFail("There was not enough time to verify the data ")
            return
        }
        
        XCTAssertFalse(Authentication, "There is a problem with the password or email sent")
        XCTAssertEqual(sutDelegate.error, error, "The error received does not match")
        
    }

}




