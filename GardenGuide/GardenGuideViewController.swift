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

class GardenGuideViewController: UIViewController {

    @IBOutlet weak var closeSessionButton: UIButton!
    
    var email: String = ""
    var provider: ProviderType = .none
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(email)
        print(provider)
        saveUser(email: email, provider: provider)
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
    
}
