//
//  GardenGuideViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/04/24.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn
import FirebaseRemoteConfig
import FirebaseFirestore

class GardenGuideViewController: UIViewController {

    @IBOutlet weak var closeSessionButton: UIButton!
    
    @IBOutlet weak var errorButton: UIButton!
    
    @IBOutlet weak var infoLabel: UITextField!
    var email: String = ""
    var provider: ProviderType = .none
    private let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(email)
        print(provider)
        saveUser(email: email, provider: provider)
        
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.fetchAndActivate{ (status, error) in
            if status != .error {
                let showErrorButton = remoteConfig.configValue(forKey: "show_error_button").boolValue
                let errorButtonText = remoteConfig.configValue(forKey: "error_Button_text").stringValue
                
                DispatchQueue.main.async {
                    self.errorButton.isHidden = !showErrorButton
                    self.errorButton.setTitle(errorButtonText, for: .normal)
                }
                
            }
            
        }
        
    }
    
    func saveUser(email: String, provider: ProviderType) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        defaults.synchronize()
        print("usuario guardado")
    }
    func removeUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "provider")
        defaults.synchronize()
        print("usuario eliminado")
    }
    
    

    
    @IBAction func closeSession(_ sender: Any) {
        removeUser()
        switch provider {
        case .email:
            firabaseLogOut()
        case .google:
            GIDSignIn.sharedInstance.signOut()
            firabaseLogOut()
        case .none:
            print("Guadra datos plis")
        case .anonymous:
            firabaseLogOut()
        case .twitter:
            firabaseLogOut()
        }
        
        let authStoryboard = UIStoryboard(name: "AuthMain", bundle: .main)
        if let authMainViewController = authStoryboard.instantiateViewController(withIdentifier: "AuthMainVC") as? AuthMainViewController {
            view.window?.windowScene?.keyWindow?.rootViewController = authMainViewController
            view.window?.windowScene?.keyWindow?.makeKeyAndVisible()
        }
        
    }
    
    private func firabaseLogOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            print("se cerro")
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func ConfigError(_ sender: Any) {
        fatalError("Crash was triggered")
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        view.endEditing(true)
        db.collection("users").document(email).setData([
            "provider": provider.rawValue,
            "text": infoLabel.text ?? ""
        ])
    }
    
    @IBAction func recuperarButton(_ sender: Any) {
        view.endEditing(true)
        db.collection("users").document(email).getDocument { (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let text = document.get("text") as? String {
                    self.infoLabel.text = text
                } else {
                    self.infoLabel.text = ""
                }
            }
        }
    }
    
    @IBAction func removeButton(_ sender: Any) {
        view.endEditing(true)
        db.collection("users").document(email).delete()
    }
    
}
