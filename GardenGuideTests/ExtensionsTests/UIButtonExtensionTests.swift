//
//  UIButtonExtensionTests.swift
//  GardenGuideTests
//
//  Created by Donovan Z. Jaimes on 19/04/24.
//

import XCTest
@testable import GardenGuide

final class UIButtonExtensionTests: XCTestCase {
    var button : UIButton!
    
    override func setUpWithError() throws {
        button = UIButton()
    }

    override func tearDownWithError() throws {
        button = nil
    }

    func test_modifyCornerRadius_WithAButton() {
        //Arrange
        let radius: CGFloat = 10
        let width: CGFloat = 0
        
        //Act
        button.modifyCornerRadius(radius)
        
        //Assert
        XCTAssertEqual(button.layer.cornerRadius, radius,"The radius does not match")
        XCTAssertEqual(button.layer.borderWidth, width,"The border width does not match")
        
    }
    
    func test_modifyCornerRadius_AndBorderColor_WithAButton() {
        //Arrange
        let radius: CGFloat = 5
        let color: UIColor = .opaqueGray
        let width: CGFloat = 0
        
        //Act
        button.modifyCornerRadius(radius,withColor: color)
        
        //Assert
        XCTAssertEqual(button.layer.cornerRadius, radius, "The radius does not match")
        XCTAssertEqual(button.layer.borderColor, color.cgColor, "The border color does not match")
        XCTAssertEqual(button.layer.borderWidth, width,"The border width does not match")
        
    }
    
    func test_modifyCornerRadius_WithBorderColor_AndWidth_WithAButton() {
        //Arrange
        let radius: CGFloat = 1
        let color: UIColor = .opaqueGray
        let width: CGFloat = 1
        
        //Act
        button.modifyCornerRadius(radius,withColor: color,andWidth: width)
        
        //Assert
        XCTAssertEqual(button.layer.cornerRadius, radius, "The radius does not match")
        XCTAssertEqual(button.layer.borderColor, color.cgColor,  "The border color does not match")
        XCTAssertEqual(button.layer.borderWidth, width,"The border width does not match")
    }
    
}
