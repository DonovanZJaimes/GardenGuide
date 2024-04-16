//
//  AuthMainController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 11/04/24.
//

import Foundation
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

protocol AuthMainViewProtocol: AnyObject {
    //func verifyAuthentication2(result: AuthDataResult?, error: Error?, provider: ProviderType, id: String?)
    func successfulAuthentication(provider: ProviderType, email: String)
    func failedAuthentication(error: String)
}

class AuthMainController {
    weak var delegate: AuthMainViewProtocol?
    weak var viewController: AuthMainViewController?
    private var provider: OAuthProvider?
    
    init(delegate: AuthMainViewProtocol, viewController: AuthMainViewController = AuthMainViewController()) {
        self.viewController = viewController
        self.delegate = delegate
    }
    
    
    //MARK: Google
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController! ) { [weak self] result, error in
          guard error == nil else {
              //throw error
              return
          }
          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
            else {
              //throw error
              return
          }
          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                self?.verifyAuthentication(result: result, error: error, provider: .google)
                
                
            }
        }
    }
    
    //MARK: Anonymous
    func signUpAnonymously() {
        Auth.auth().signInAnonymously { (authResult, error) in
            guard error == nil else {
                //throw error
                return
            }
            guard let user = authResult?.user else { return }
            let uid = user.uid
            self.verifyAuthentication(result: authResult, error: error, provider: .anonymous, id: uid)
        }
        
    }
    
    //MARK: Twitter
    func signInWithTwitter() {
        provider = OAuthProvider(providerID: "twitter.com")
        provider?.getCredentialWith(nil) { credential, error in
              if error != nil {
                // Handle error.
              }
              if credential != nil {
                  Auth.auth().signIn(with: credential!) { authResult, error in
                  if error != nil {
                    // Handle error.
                  }
                      self.verifyAuthentication(result: authResult, error: error, provider: .twitter)
                }
              }
            }

    }
    
    //MARK: Email
    func signInWithEmail(_ email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (result , error) in
            self.verifyAuthentication(result: result, error: error, provider: .email)
        }
    }
    
    func signUpWithEmail(_ email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result , error) in
            self.verifyAuthentication(result: result, error: error, provider: .email)
        }
        
    }
    
    func verifyAuthentication(result: AuthDataResult?, error: Error?, provider: ProviderType, id: String? = nil) {
        if let result = result, error == nil {
            let email = id == nil ? (result.user.email ?? result.user.displayName)! : id!
            delegate?.successfulAuthentication(provider: provider, email: email)
        } else {
            let errorMessage = analyzeError(error.debugDescription)
            delegate?.failedAuthentication(error: errorMessage)
        }
        
    }
    
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
