//
//  NetworkErrorFirebase.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 15/04/24.
//

import Foundation

enum NetworkErrorFirebase: String, Error, CaseIterable {
    case ErrorEmailAlredyInUse // 17007
    case ErrorWeakPassword // 17026
    case ErrorMissingEmail // 17034
    case ErrorInvalidEmail // 17008
    case ErrorInvalidPassword // 17004
    case ErrorWrongPassword // 17009
    case ErrorGeneric //
}

extension NetworkErrorFirebase: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .ErrorEmailAlredyInUse:
            return NSLocalizedString("The email address is already in use by another account", comment: "")
        case .ErrorWeakPassword:
            return NSLocalizedString("The password must be 6 characters long or more", comment: "")
        case .ErrorMissingEmail:
            return NSLocalizedString("An email address must be provided", comment: "")
        case .ErrorInvalidEmail:
            return NSLocalizedString("The email address is badly formatted", comment: "")
        case .ErrorInvalidPassword:
            return NSLocalizedString("The password is invalid or the user does not have a password", comment: "")
        case .ErrorWrongPassword:
            return NSLocalizedString("The password is invalid or the user does not have a password", comment: "")
        case .ErrorGeneric:
            return NSLocalizedString("Authentication failed. Try again late", comment: "")
        }
    }
    
    public var errorCode: String {
        switch self {
        case .ErrorEmailAlredyInUse:
            return "17007"
        case .ErrorWeakPassword:
            return "17026"
        case .ErrorMissingEmail:
            return "17034"
        case .ErrorInvalidEmail:
            return "17008"
        case .ErrorInvalidPassword:
            return "17004"
        case .ErrorWrongPassword:
            return "17009"
        case .ErrorGeneric:
            return "170"
        }
    }
}

extension NetworkErrorFirebase  {
    func analyzeError(_ error: String) -> String {
        var errorMessage: String = ""
        switch error {
        case _ where error.contains(NetworkErrorFirebase.ErrorEmailAlredyInUse.errorCode):
            errorMessage = NetworkErrorFirebase.ErrorEmailAlredyInUse.errorDescription!
        case _ where error.contains(NetworkErrorFirebase.ErrorWeakPassword.errorCode):
            errorMessage = NetworkErrorFirebase.ErrorWeakPassword.errorDescription!
        case _ where error.contains(NetworkErrorFirebase.ErrorMissingEmail.errorCode):
            errorMessage = NetworkErrorFirebase.ErrorMissingEmail.errorDescription!
        case _ where error.contains(NetworkErrorFirebase.ErrorInvalidEmail.errorCode):
            errorMessage = NetworkErrorFirebase.ErrorInvalidEmail.errorDescription!
        case _ where error.contains(NetworkErrorFirebase.ErrorInvalidPassword.errorCode):
            errorMessage = NetworkErrorFirebase.ErrorInvalidPassword.errorDescription!
        case _ where error.contains(NetworkErrorFirebase.ErrorWrongPassword.errorCode):
            errorMessage = NetworkErrorFirebase.ErrorWrongPassword.errorDescription!
        default:
            errorMessage = NetworkErrorFirebase.ErrorGeneric.errorDescription!
        }
        return errorMessage
    }
}


/**
 signup
 correo existente contaseña mal:
 Error Domain=FIRAuthErrorDomain Code=17007 "The email address is already in use by another account." UserInfo={NSLocalizedDescription=The email address is already in use by another account., FIRAuthErrorUserInfoNameKey=ERROR_EMAIL_ALREADY_IN_USE}
 
 
 correo existene sin contaseña
 Error Domain=FIRAuthErrorDomain Code=17026 "The password must be 6 characters long or more." UserInfo={FIRAuthErrorUserInfoNameKey=ERROR_WEAK_PASSWORD, NSLocalizedFailureReason=Missing Password, NSLocalizedDescription=The password must be 6 characters long or more.}
 
 sin correo y sin contaseña
 Error Domain=FIRAuthErrorDomain Code=17026 "The password must be 6 characters long or more." UserInfo={FIRAuthErrorUserInfoNameKey=ERROR_WEAK_PASSWORD, NSLocalizedFailureReason=Missing Password, NSLocalizedDescription=The password must be 6 characters long or more.}
 
 sin correo y contasea bien
 Error Domain=FIRAuthErrorDomain Code=17034 "An email address must be provided." UserInfo={NSLocalizedDescription=An email address must be provided., FIRAuthErrorUserInfoNameKey=ERROR_MISSING_EMAIL}
 
 correo bueno sin contaseña o con contraseña pequeña
 Error Domain=FIRAuthErrorDomain Code=17026 "The password must be 6 characters long or more." UserInfo={FIRAuthErrorUserInfoNameKey=ERROR_WEAK_PASSWORD, NSLocalizedFailureReason=Missing Password, NSLocalizedDescription=The password must be 6 characters long or more.}
 
 correo posiblemente malo sin contaseña
 Error Domain=FIRAuthErrorDomain Code=17026 "The password must be 6 characters long or more." UserInfo={FIRAuthErrorUserInfoNameKey=ERROR_WEAK_PASSWORD, NSLocalizedFailureReason=Missing Password, NSLocalizedDescription=The password must be 6 characters long or more.}
 
 correo posiblemete malo con contaseña pequeña
 Error Domain=FIRAuthErrorDomain Code=17008 "The email address is badly formatted." UserInfo={NSLocalizedDescription=The email address is badly formatted., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_EMAIL}
 
 correo malo sin contraseña
 Error Domain=FIRAuthErrorDomain Code=17026 "The password must be 6 characters long or more." UserInfo={FIRAuthErrorUserInfoNameKey=ERROR_WEAK_PASSWORD, NSLocalizedFailureReason=Missing Password, NSLocalizedDescription=The password must be 6 characters long or more.}
 
 correo malo contraseña peqeña
 Error Domain=FIRAuthErrorDomain Code=17008 "The email address is badly formatted." UserInfo={NSLocalizedDescription=The email address is badly formatted., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_EMAIL}
 
 coreo malo y contraseña bien
 Error Domain=FIRAuthErrorDomain Code=17008 "The email address is badly formatted." UserInfo={NSLocalizedDescription=The email address is badly formatted., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_EMAIL}
 
 
 
 
 login
 correo existente contaseña mal:
 Error Domain=FIRAuthErrorDomain Code=17004 "The supplied auth credential is malformed or has expired." UserInfo={NSLocalizedDescription=The supplied auth credential is malformed or has expired., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_CREDENTIAL}
 
 
 correo existene sin contaseña
 Error Domain=FIRAuthErrorDomain Code=17009 "The password is invalid or the user does not have a password." UserInfo={NSLocalizedDescription=The password is invalid or the user does not have a password., FIRAuthErrorUserInfoNameKey=ERROR_WRONG_PASSWORD}
 
 sin correo y sin contaseña
 Error Domain=FIRAuthErrorDomain Code=17009 "The password is invalid or the user does not have a password." UserInfo={NSLocalizedDescription=The password is invalid or the user does not have a password., FIRAuthErrorUserInfoNameKey=ERROR_WRONG_PASSWORD}
 
 sin correo y contasea bien
 Error Domain=FIRAuthErrorDomain Code=17008 "The email address is badly formatted." UserInfo={NSLocalizedDescription=The email address is badly formatted., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_EMAIL}
 
 correo buenos sin contaseña
 Error Domain=FIRAuthErrorDomain Code=17009 "The password is invalid or the user does not have a password." UserInfo={NSLocalizedDescription=The password is invalid or the user does not have a password., FIRAuthErrorUserInfoNameKey=ERROR_WRONG_PASSWORD}
 
 correo buenos y con contaseña pequeña
 Error Domain=FIRAuthErrorDomain Code=17004 "The supplied auth credential is malformed or has expired." UserInfo={NSLocalizedDescription=The supplied auth credential is malformed or has expired., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_CREDENTIAL}
 
 correo posiblemente malo sin contaseña
 Error Domain=FIRAuthErrorDomain Code=17009 "The password is invalid or the user does not have a password." UserInfo={NSLocalizedDescription=The password is invalid or the user does not have a password., FIRAuthErrorUserInfoNameKey=ERROR_WRONG_PASSWORD}
 
 correo posiblemete malo con contaseña pequeña
 Error Domain=FIRAuthErrorDomain Code=17004 "The supplied auth credential is malformed or has expired." UserInfo={NSLocalizedDescription=The supplied auth credential is malformed or has expired., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_CREDENTIAL}
 
 correo malo sin contraseña
 Error Domain=FIRAuthErrorDomain Code=17009 "The password is invalid or the user does not have a password." UserInfo={NSLocalizedDescription=The password is invalid or the user does not have a password., FIRAuthErrorUserInfoNameKey=ERROR_WRONG_PASSWORD}
 
 correo malo contraseña peqeña
 Error Domain=FIRAuthErrorDomain Code=17008 "The email address is badly formatted." UserInfo={NSLocalizedDescription=The email address is badly formatted., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_EMAIL}
 
 coreo malo y contraseña bien
 Error Domain=FIRAuthErrorDomain Code=17008 "The email address is badly formatted." UserInfo={NSLocalizedDescription=The email address is badly formatted., FIRAuthErrorUserInfoNameKey=ERROR_INVALID_EMAIL}
 */




/**
 17007: ErrorEmailAlredyInUse
 Correo ya se esta usando
 
 17026: ErrorWeakPassword
 contraseña (mala) o pequeña
 
 17034: ErrorMissingEmail
 no se ingreso correo
 
 17008: ErrorInvalidEmail
 correo invalido
 
 17004: ErrorInvalidPassword
 contaseña equivocada, credencial mala
 
 17009: ErrorWrongPassword
 contaseña equivocada
 */
