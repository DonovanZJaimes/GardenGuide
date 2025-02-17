//
//  AuthMainSnapshotTests.swift
//  GardenGuideUnitTests
//
//  Created by Donovan Z. Jaimes on 14/02/25.
//

import XCTest
@testable import GardenGuide
import SnapshotTesting


final class AuthMainSnapshotTests: XCTestCase {

    func test_LoginAuth_mainViewOf_AuthMain() throws {
        //Arrange
        let storyboard = UIStoryboard(name: "AuthMain", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AuthMainVC") as! AuthMainViewController
        //Act
        //Assert
        assertSnapshot(of: vc, as: .image)
    }
    
    
    func test_LoginAuth_mainViewOf_AuthMain_withPasswordAndEmail() throws {
        //Arrange
        let storyboard = UIStoryboard(name: "AuthMain", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AuthMainVC") as! AuthMainViewController
        
        //Act
        vc.loadViewIfNeeded()
        vc.emailTextField.text = "email@gmail.com"
        vc.passwordTextField.text = "password"
        vc.editingEmailTextField(vc.emailTextField)
        
        //Assert
        assertSnapshot(of: vc, as: .image)
    }
    

}
