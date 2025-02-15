//
//  MockManagerSingletonTests.swift
//  GardenGuideUnitTests
//
//  Created by Donovan Z. Jaimes on 14/02/25.
//

import XCTest
@testable import GardenGuide

final class MockManagerSingletonTests: XCTestCase {

    var mockTriggering: Bool!
    var noMockTriggering: Bool!
    
    override func setUpWithError() throws {
       mockTriggering = true
       noMockTriggering = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_verifyRunAppWithMock_mockTriggering() throws {
        //Arrange
        let isTrue = true
        //Act
        MockManagerSingleton.shared.runAppWithMock = mockTriggering
        let result = MockManagerSingleton.shared.runAppWithMock
        //Assert
        XCTAssertEqual(result, isTrue, "Mock Manager singleton does not work")
    }

    func test_verifyRunAppWithMock_noMockTriggering() throws {
        //Arrange
        let isFalse = false
        //Act
        MockManagerSingleton.shared.runAppWithMock = noMockTriggering
        let result = MockManagerSingleton.shared.runAppWithMock
        //Assert
        XCTAssertEqual(result, isFalse, "Mock Manager singleton does not work")
    }
}

