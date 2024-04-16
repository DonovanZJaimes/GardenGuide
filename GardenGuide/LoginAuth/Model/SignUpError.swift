//
//  SignUpError.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 15/04/24.
//

import Foundation

enum SignUpError: String, Error {
    case invalidPassword
    case invalidEmail
}

extension SignUpError: LocalizedError {
    public var localizedDescription: String? {
        switch self {
        case .invalidPassword:
            return NSLocalizedString("The password must have at least one lowercase letter, one uppercase letter, one number, and one special character", comment: "")
        case .invalidEmail:
            return NSLocalizedString("The email address is invalid", comment: "")
        }
    }
}
