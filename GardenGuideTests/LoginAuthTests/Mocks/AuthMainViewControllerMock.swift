//
//  AuthMainViewControllerMock.swift
//  GardenGuideTests
//
//  Created by Donovan Z. Jaimes on 24/04/24.
//
import XCTest
@testable import GardenGuide


class AuthMainViewControllerMock: AuthMainViewProtocol {
    var IsTheAuthenticationSuccessful: Bool? = nil
    var provider: ProviderType!
    var email: String!
    var expectation: XCTestExpectation?
    var error: String!
    
    func successfulAuthentication(provider: GardenGuide.ProviderType, email: String) {
        IsTheAuthenticationSuccessful = true
        self.provider = provider
        self.email = email
        expectation?.fulfill()
        
    }
    
    func failedAuthentication(error: String) {
        IsTheAuthenticationSuccessful = false
        self.error = error
        expectation?.fulfill()
    }
    
    
}

