//
//  GardenGuideUITests.swift
//  GardenGuideUITests
//
//  Created by Donovan Z. Jaimes on 17/02/25.
//

import XCTest
//@testable import GardenGuide

final class GardenGuideUITests: XCTestCase {
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }


    func test_EnterAndExit_withEmailAndPassword() throws {
        let app = XCUIApplication()
        app.launch()
        
        //Enter
        let textFieldEmail = app.textFields["Email"]
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(textFieldEmail.exists)
        XCTAssertTrue(passwordSecureTextField.exists)
        textFieldEmail.tap()
        textFieldEmail.typeText("GardenGuidePrueba1@gmail.com")
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Garden1!")
        XCTAssertEqual(textFieldEmail.value as? String, "GardenGuidePrueba1@gmail.com")
        app/*@START_MENU_TOKEN@*/.staticTexts["Log In"]/*[[".buttons[\"Log In\"].staticTexts[\"Log In\"]",".staticTexts[\"Log In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //Exit
        app.tabBars["Tab Bar"].buttons["Garden"].tap()
        let verticalScrollBar1PageCollectionView = app/*@START_MENU_TOKEN@*/.collectionViews.containing(.other, identifier:"Vertical scroll bar, 1 page").element/*[[".collectionViews.containing(.other, identifier:\"Horizontal scroll bar, 1 page\").element",".collectionViews.containing(.other, identifier:\"Vertical scroll bar, 1 page\").element"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.navigationBars["GARDEN"].buttons["gearshape"].tap()
        app.staticTexts["Sign Out"].tap()
        let elementsQuery = app.alerts["Sure you want to log out?"].scrollViews.otherElements
        elementsQuery.staticTexts["You are logged in with the account: gardenguideprueba1@gmail.com"].tap()
        elementsQuery.buttons["Yes, close it"].tap()
        
        //wait 1 second to save all
        let expectation = expectation(description: "wait 1 second")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }
    
    func test_EnterAndExit_anonymously() throws {
        let app = XCUIApplication()
        app.launch()
        
        //Enter
        XCUIApplication().buttons["close"].tap()
        
        //Exit
        app.tabBars["Tab Bar"].buttons["Garden"].tap()
        let verticalScrollBar1PageCollectionView = app/*@START_MENU_TOKEN@*/.collectionViews.containing(.other, identifier:"Vertical scroll bar, 1 page").element/*[[".collectionViews.containing(.other, identifier:\"Horizontal scroll bar, 1 page\").element",".collectionViews.containing(.other, identifier:\"Vertical scroll bar, 1 page\").element"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.navigationBars["GARDEN"].buttons["gearshape"].tap()
        app.staticTexts["Sign Out"].tap()
        let elementsQuery = app.alerts["You registered anonymously, are you sure you want to log out?"].scrollViews.otherElements
        elementsQuery.buttons["Yes, close it"].tap()
    }
    
    func test_registerWithBadPassword() throws {
        let app = XCUIApplication()
        app.launch()
    
        let textFieldEmail = app.textFields["Email"]
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(textFieldEmail.exists)
        XCTAssertTrue(passwordSecureTextField.exists)
        textFieldEmail.tap()
        textFieldEmail.typeText("GardenGuidePrueba1@gmail.com")
        passwordSecureTextField.tap()
        //add password
        passwordSecureTextField.typeText("Garden1")
        XCTAssertEqual(textFieldEmail.value as? String, "GardenGuidePrueba1@gmail.com")
        app/*@START_MENU_TOKEN@*/.staticTexts["Sign Up"]/*[[".buttons[\"Sign Up\"].staticTexts[\"Sign Up\"]",".staticTexts[\"Sign Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let errorText = app.staticTexts["The password must have at least one lowercase letter, one uppercase letter, one number, and one special character"]
        XCTAssertTrue(errorText.exists)
        
    }
    
    func test_registerWithBadEmail() throws {
        let app = XCUIApplication()
        app.launch()
        
        let textFieldEmail = app.textFields["Email"]
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(textFieldEmail.exists)
        XCTAssertTrue(passwordSecureTextField.exists)
        textFieldEmail.tap()
        //add email
        textFieldEmail.typeText("GardenGuidePrueba1@.com")
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Garden1!")
        XCTAssertEqual(textFieldEmail.value as? String, "GardenGuidePrueba1@.com")
        app/*@START_MENU_TOKEN@*/.staticTexts["Sign Up"]/*[[".buttons[\"Sign Up\"].staticTexts[\"Sign Up\"]",".staticTexts[\"Sign Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let errorText = app.staticTexts["The email address is invalid"]
        XCTAssertTrue(errorText.exists)
    }
    
    func test_registerWithBadEmail_theEmailIsAlreadyRegistered() throws {
        let app = XCUIApplication()
        app.launch()
        
        let textFieldEmail = app.textFields["Email"]
        let passwordSecureTextField = app.secureTextFields["Password"]
        XCTAssertTrue(textFieldEmail.exists)
        XCTAssertTrue(passwordSecureTextField.exists)
        textFieldEmail.tap()
        //add email
        textFieldEmail.typeText("GardenGuidePrueba1@gmail.com")
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Garden1!")
        XCTAssertEqual(textFieldEmail.value as? String, "GardenGuidePrueba1@gmail.com")
        app/*@START_MENU_TOKEN@*/.staticTexts["Sign Up"]/*[[".buttons[\"Sign Up\"].staticTexts[\"Sign Up\"]",".staticTexts[\"Sign Up\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Wait until the label with the expected text is visible.
        let errorText = app.staticTexts["The email address is already in use by another account"]
        let existsPredicate = NSPredicate(format: "exists == true")
        
        // Define the expectation
        let expectation = expectation(for: existsPredicate, evaluatedWith: errorText, handler: nil)

        // Wait up to 3 seconds for the label to appear.
        wait(for: [expectation], timeout: 3)
        XCTAssertTrue(errorText.exists)
        
    }
    
    
    
 
  
}
