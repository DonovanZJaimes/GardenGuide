//
//  UIColorExtensionTests.swift
//  GardenGuideTests
//
//  Created by Donovan Z. Jaimes on 19/04/24.
//

import XCTest
@testable import GardenGuide

final class UIColorExtensionTests: XCTestCase {
    var opaqueGray: UIColor!

    func test_opaqueGray_CheckIfTheColorMatches() {
        //Arrange
        opaqueGray = UIColor(named: "OpaqueGray")
        
        //Asert
        XCTAssertEqual(opaqueGray, .opaqueGray, "The extension for the opaqueGray color is not the same")
    }
    
    
   

}
