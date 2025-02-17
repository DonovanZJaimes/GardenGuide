//
//  ProviderTypeTests.swift
//  GardenGuideUnitTests
//
//  Created by Donovan Z. Jaimes on 14/02/25.
//

import XCTest
@testable import GardenGuide

final class ProviderTypeTests: XCTestCase {

    func test_ProviderType_DetermineNumberOfCases() throws {
        //Arrange
        let cases: Int = 5 // The ProviderType has 5 cases
        //Act
        //Assert
        XCTAssertEqual(ProviderType.allCases.count, cases, "The number of cases is incorrect")
        
    }
    
    func test_ProviderType_DetermineTehRawValueOfCases() {
        //Arrange
        let providerAnonymous = "anonymous"
        let providerEmail = "email"
        let providerGoogle = "google"
        let providerNone = "none"
        let providerTwitter = "twitter"
        
        //Act
        //Assert
        XCTAssertEqual(providerAnonymous, ProviderType.anonymous.rawValue, "The case name is incorrect")
        XCTAssertEqual(providerEmail, ProviderType.email.rawValue, "The case name is incorrect")
        XCTAssertEqual(providerGoogle, ProviderType.google.rawValue, "The case name is incorrect")
        XCTAssertEqual(providerNone, ProviderType.none.rawValue, "The case name is incorrect")
        XCTAssertEqual(providerTwitter, ProviderType.twitter.rawValue, "The case name is incorrect")
        
        
    }

}
