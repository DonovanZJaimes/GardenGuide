//
//  SettingsController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 18/01/25.
//

import Foundation
import FirebaseAuth

//MARK: Delegate for SettingView
protocol SettingsControllerDelegate: AnyObject {
    func userInformationWasObtained (providerType: ProviderType, email: String)
    func successfulAuthentication(provider: ProviderType, email: String)
    func failedAuthentication(error: String)
}

//MARK: Controller for SettingView
class SettingsController {
    weak var delegate: SettingsControllerDelegate?
    var provider: SettingsProvider
    
    init(delegate: SettingsControllerDelegate, provider: SettingsProvider = SettingsProvider()) {
        self.delegate = delegate
        self.provider = provider
    }
    
    //MARK: General methods
    
    //get user's email and provider
    func obtainUserInformation() {
        let (providerType, email) = provider.getUserProvider()
        delegate?.userInformationWasObtained(providerType: providerType, email: email)
    }
    
    //try to sign Up with anonymously account
    func signUpWithEmail(_ email: String, password: String, user: User?, uid: String) {
        //in case the user account has not expired
        guard let user = user else {
            tryToGetTheSameAnonymousAccount { user in
                //check if it is the same anonymously account
                guard let user = user, user.uid == uid else {
                    self.delegate?.failedAuthentication(error: "The anonymous account provided is malformed or has expired.")
                    return
                }
                self.signUpWithCredential(email: email, password: password, user: user)
            }
            return
        }
        signUpWithCredential(email: email, password: password, user: user)
       
    }
    
    private func tryToGetTheSameAnonymousAccount(completion: @escaping (User?) -> Void) {
        Auth.auth().signInAnonymously { (authResult, error) in
            if let result = authResult, error == nil {
                completion(result.user)
            }
        }
    }
    
    private func signUpWithCredential(email: String, password: String, user: User) {
        //try to get new credential on Firebase
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.link(with: credential) { (authResult, error) in
            guard error == nil else {
                //throw error
                let errorMessage = NetworkErrorFirebase.ErrorGeneric.analyzeError(error.debugDescription)
                self.delegate?.failedAuthentication(error: errorMessage)
                return
            }
            guard let user = authResult?.user else { return }
            let uid = user.uid
            self.verifyAuthentication(result: authResult, error: error, provider: .email, id: uid)
            
        }
    }
    
    private func verifyAuthentication(result: AuthDataResult?, error: Error?, provider: ProviderType, id: String? = nil) {
        if let result = result, error == nil {
            let email = result.user.email  ?? id!
            delegate?.successfulAuthentication(provider: provider, email: email)
        } else {
            let errorMessage = NetworkErrorFirebase.ErrorGeneric.analyzeError(error.debugDescription)
            delegate?.failedAuthentication(error: errorMessage)
        }
        
    }
    
    //save User To Firestore Cloud
    func saveUserToFirestoreCloud(email: String, provider: String) async  {
        await makeMethodsForFirestoreCloud {
                await FirestoreAddData.shared.addUserToCloud(with: email, andProvider: provider)
            }
    }
    
  
}
