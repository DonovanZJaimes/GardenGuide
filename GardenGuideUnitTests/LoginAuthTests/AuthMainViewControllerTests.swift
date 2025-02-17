//
//  AuthMainViewControllerTests.swift
//  GardenGuideUnitTests
//
//  Created by Donovan Z. Jaimes on 14/02/25.
//

import XCTest
@testable import GardenGuide

final class AuthMainViewControllerTests: XCTestCase {
    var sut: AuthMainViewController!
    private var rootWindow: UIWindow!
    
    override func setUpWithError() throws {
        let storyboard = UIStoryboard(name: "AuthMain", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AuthMainVC") as! AuthMainViewController
        sut = vc
        sut.loadViewIfNeeded()
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_AuthMainViewController_CheckButtonActions() throws {
        //Arrange
        let anonymousButton = try XCTUnwrap(sut.anonymousButton, "button not found")
        let logInButton = try XCTUnwrap(sut.logInButton, "button not found")
        let signUpButton = try XCTUnwrap(sut.signUpButton, "button not found")
        let twitterButton = try XCTUnwrap(sut.twitterButton, "button not found")
        let googleButton = try XCTUnwrap(sut.googleButton, "button not found")
        let actionsCount = 1
        
        //Act
        let anonymousButtonActionsCount = try XCTUnwrap(anonymousButton.actions(forTarget: sut, forControlEvent: .touchUpInside), "No actions found on button")
        let logInButtonActionsCount = try XCTUnwrap(logInButton.actions(forTarget: sut, forControlEvent: .touchUpInside), "No actions found on button")
        let signUpButtonActionsCount = try XCTUnwrap(signUpButton.actions(forTarget: sut, forControlEvent: .touchUpInside), "No actions found on button")
        let twitterButtonActionsCount = try XCTUnwrap(twitterButton.actions(forTarget: sut, forControlEvent: .touchUpInside), "No actions found on button")
        let googleButtonActionsCount = try XCTUnwrap(googleButton.actions(forTarget: sut, forControlEvent: .touchUpInside), "No actions found on button")
        
        //Assert
        XCTAssertEqual(anonymousButtonActionsCount.count, 1, "The number of actions to the button does not correspond")
        XCTAssertEqual(logInButtonActionsCount.count, 1, "The number of actions to the button does not correspond")
        XCTAssertEqual(signUpButtonActionsCount.count, 1, "The number of actions to the button does not correspond")
        XCTAssertEqual(twitterButtonActionsCount.count, 1, "The number of actions to the button does not correspond")
        XCTAssertEqual(googleButtonActionsCount.count, 1, "The number of actions to the button does not correspond")
    }
    
    func test_AuthMainViewController_CheckTextFieldsActions() throws {
        //Arrange
        let emailTextField = try XCTUnwrap(sut.emailTextField, "TextField not found")
        let passwordTextField = try XCTUnwrap(sut.passwordTextField, "TextField not found")
        let actionsCount = 1
        
        //Act
        let emailTextFieldActionsCount = try XCTUnwrap(emailTextField.actions(forTarget: sut, forControlEvent: .editingChanged), "No actions found on TextField")
        let passwordTextFieldActionsCount = try XCTUnwrap(passwordTextField.actions(forTarget: sut, forControlEvent: .editingChanged), "No actions found on TextField")
        
        //Assert
        XCTAssertEqual(emailTextFieldActionsCount.count, 1, "The number of actions to the TextField does not correspond")
        XCTAssertEqual(passwordTextFieldActionsCount.count, 1, "The number of actions to the TextField does not correspond")
        
    }
    
    func test_configEmailButtons_CheckIfTheButtonConfigurationIsCorrect () throws {
        //Arrange
        let logInButton = try XCTUnwrap(sut.logInButton, "button not found")
        let signUpButton = try XCTUnwrap(sut.signUpButton, "button not found")
        let twitterButton = try XCTUnwrap(sut.twitterButton, "button not found")
        let googleButton = try XCTUnwrap(sut.googleButton, "button not found")
        let emailButtons = [logInButton, signUpButton]
        let signInButtons =  [googleButton, twitterButton]
        let radius = logInButton.frame.height / 7
        let color: UIColor = .opaqueGray
        let cgcolor = color.cgColor
        let width = 0.3
        
        //Act
        sut.viewDidLoad()
        
        //Assert
        emailButtons.forEach { button in
            XCTAssertEqual(button.layer.cornerRadius, radius, "Wrong radio")
        }
        signInButtons.forEach { button in
            XCTAssertEqual(button.layer.cornerRadius, radius, "Wrong radio")
            XCTAssertEqual(button.layer.borderColor, cgcolor, "Wrong color")
            XCTAssertEqual(button.layer.borderWidth, width, "Wrong width")
        }
    }
    
    
    func test_viewDidDisappear_CheckTheStatusOfVariables () throws {
        //Arrange
        sut.password = "password"
        sut.email = "email"
        sut.errorLabel.isHidden = false
        XCTAssertNotNil(sut.password, "The password was not changed")
        XCTAssertNotNil(sut.email, "The email was not changed")
        XCTAssertFalse(sut.errorLabel.isHidden, "The errorLable was not changed")
        
        //Act
        sut.viewDidDisappear(true)
        
        //Assert
        XCTAssertNil(sut.password, "The password was not changed")
        XCTAssertNil(sut.email, "The email was not changed")
        XCTAssertTrue(sut.errorLabel.isHidden, "The errorLable was not changed")
        
    }
    
    func test_enableEmailButtons_WhenTheSut_viewDidLoad() throws {
        //Arrange
        sut.emailTextField.text = "email"
        sut.passwordTextField.text = "password"
        sut.signUpButton.isEnabled = false
        sut.logInButton.isEnabled = false
        
        //Act
        sut.viewDidLoad()
        
        //Assert
        XCTAssertTrue(sut.signUpButton.isEnabled, "buttons were not enabled")
        XCTAssertTrue(sut.logInButton.isEnabled, "buttons were not enabled" )
        
    }
    func test_disableEmailButtons_WhenTheSut_viewDidLoad() throws {
        //Arrange
        sut.emailTextField.text = ""
        sut.passwordTextField.text = ""
        sut.signUpButton.isEnabled = true
        sut.logInButton.isEnabled = true
        
        //Act
        sut.viewDidLoad()
        
        //Assert
        XCTAssertFalse(sut.signUpButton.isEnabled, "buttons are not disabled")
        XCTAssertFalse(sut.logInButton.isEnabled, "buttons are not disabled" )
        
    }
    
    func test_editingEmailTextField_CheckTheStatusOfEmail() {
        //Arrange
        sut.email = "email"
        let email = "email@gmail.com"
        sut.emailTextField.text = email
        
        //Act
        sut.editingEmailTextField(sut.emailTextField)
        
        //Assert
        XCTAssertEqual(sut.email, email, "The text was not changed")
    }
    
    func test_editingEmailTextField_CheckTheStatusOfEmail_WithAnInvalidEmail() {
        //Arrange
        sut.email = "email"
        sut.emailTextField.text = "email@.com"
        
        //Act
        sut.editingEmailTextField(sut.emailTextField)
        
        //Assert
        XCTAssertNil(sut.email, "The text was not changed or the email is invalid")
    }
    
    func test_editingPasswordTextField_WithAnValidPassword () throws {
        //Arrange
        let password = "Ϯ𝛽𑬈९"
        sut.emailTextField.text = "email"
        sut.passwordTextField.text = password
        sut.password = nil
        sut.signUpButton.isEnabled = false
        sut.logInButton.isEnabled = false
        
        //Act
        sut.editingPasswordTextField(sut.passwordTextField)
        
        //Assert
        
        XCTAssertNotNil(sut.password)
        XCTAssertTrue(sut.signUpButton.isEnabled)
        XCTAssertTrue(sut.logInButton.isEnabled)
        
    }
    func test_editingPasswordTextField_WithAnInvalidPassword () throws {
        //Arrange
        let wrongPassword = "Ϯ𝛽𑬈"
        sut.emailTextField.text = ""
        sut.passwordTextField.text = wrongPassword
        sut.password = "Ϯ𝛽𑬈९"
        sut.signUpButton.isEnabled = true
        sut.logInButton.isEnabled = true
        
        //Act
        sut.editingPasswordTextField(sut.passwordTextField)
        
        //Assert
        XCTAssertNil(sut.password)
        XCTAssertFalse(sut.signUpButton.isEnabled)
        XCTAssertFalse(sut.logInButton.isEnabled)
        
    }
    
    /*
    func test_goToGardenGuideViewController() {
        //Arrange
        let email = "usuario1"
        let provider: ProviderType = .none
        
        //Act
        sut.goToGardenGuideViewController(email: email, provider: provider)
        //Assert
        /*print(sut.view.window?.rootViewController.)
       // sut.view.window?.rootViewController?.isKind(of: true)
        XCTAssertTrue(true)
        //let h = self.view.window?.windowScene?.keyWindow?.rootViewController
       */
        guard let rootWindow = rootWindow as? UIWindow,
                    let rootViewController = rootWindow.rootViewController as? GardenGuideViewController else {
                        XCTFail("tearDownTopLevelUI() was called without setupTopLevelUI() being called first")
                        return
                }
                XCTAssertTrue(true)
    }
    
    
    
     private func goToGardenGuideViewController(email: String, provider: ProviderType) {
         let gardenGuideStoryboard = UIStoryboard(name: "GardenGuide", bundle: .main)
         if let gardenGuideTabBarController = gardenGuideStoryboard.instantiateViewController(withIdentifier: "GardenGuideTBC") as? UITabBarController,  let gardenGuideViewController = gardenGuideStoryboard.instantiateViewController(withIdentifier: "GardenGuideVC") as? GardenGuideViewController {
             
             gardenGuideViewController.email = email
             gardenGuideViewController.provider = provider
             
             gardenGuideTabBarController.viewControllers?[0] = gardenGuideViewController
             
             self.view.window?.windowScene?.keyWindow?.rootViewController = gardenGuideTabBarController
             self.view.window?.windowScene?.keyWindow?.makeKeyAndVisible()
         }
         
     }
     
     
     // instanciamos una vista para presentarla
     let recipeSearchList = UIStoryboard(name: "RecipeSearchList", bundle: .main)
     //Instanciamos un RecipeSearchListViewController
     if let recipeSearchListViewController = recipeSearchList.instantiateViewController(withIdentifier: "RecipeSearchListVC") as? RecipeSearchListViewController {
         self.navigationController?.pushViewController(recipeSearchListViewController, animated: true)
     }
     
     
     */
}

