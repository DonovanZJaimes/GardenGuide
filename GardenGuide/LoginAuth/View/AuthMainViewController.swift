//
//  AuthMainViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/04/24.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseRemoteConfig

class AuthMainViewController: UIViewController, AuthUIDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var singUpButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    lazy var delegate = AuthMainController(delegate: self, viewController: self)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 60
        
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(["show_Sign_In_Button": NSNumber(true), "error_Button_text":NSString("MuestrameError"), "show_error_button":NSNumber(true)])
        
        
        remoteConfig.fetchAndActivate{ (status, error) in
            if status != .error {
                let showSignInButton = remoteConfig.configValue(forKey: "show_Sign_In_Button").boolValue
                
                DispatchQueue.main.async {
                    self.signInButton.isHidden = !showSignInButton
                }
                
            }
            
        }
        
    }
    
    func configureButtons() {
        let buttonsEmail = [logInButton, singUpButton]
        buttonsEmail.forEach { button in
            button?.layer.cornerRadius = (button?.frame.height)!/7
            
        }
        let borderColor = UIColor(named: "Opaque Separator Color") /***Color del borde*/
        let buttonsSignIn =  [googleButton, twitterButton]
        buttonsSignIn.forEach { button in
            button!.layer.cornerRadius = (button?.frame.height)!/7
            button!.layer.borderColor = borderColor?.cgColor
            button!.layer.borderWidth = 0.1
        }
        
    }
    
    //MARK: Email Auth
    @IBAction func logInButtonAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            delegate.signInWithEmail(email, password: password)
        }
    }
    
    @IBAction func singUpButtonAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            delegate.singUpWithEmail( email, password: password)
        }
    }
    
   //MARK: Google Auth
    @IBAction func signInWithGoogle(_ sender: GIDSignInButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
              //throw error
              //print(error as Any)
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
            Auth.auth().signIn(with: credential) { result, error in
                self.goToGardenGuideViewController(result: result, error: error, provider: .google)
            }
        }
    }
    
    //MARK: Google Auth
    @IBAction func signInWithGoogle2(_ sender: UIButton) {
        delegate.signInWithGoogle()
    }
    
    //MARK: Anonymous Auth
    @IBAction func signUpAnonymously(_ sender: Any) {
        delegate.signUpAnonymously()
    }
    
    @IBAction func twitterButtonAction(_ sender: Any) {
        delegate.signInWithTwitter()
    }
    
    func goToGardenGuideViewController(result: AuthDataResult?, error: Error?, provider: ProviderType, id: String? = nil) {
        if let result = result, error == nil {
            
            let gardenGuideStoryboard = UIStoryboard(name: "GardenGuide", bundle: .main)
            if let gardenGuideTabBarController = gardenGuideStoryboard.instantiateViewController(withIdentifier: "GardenGuideTBC") as? UITabBarController,  let gardenGuideViewController = gardenGuideStoryboard.instantiateViewController(withIdentifier: "GardenGuideVC") as? GardenGuideViewController {
                let email = id == nil ? (result.user.email ?? result.user.displayName)! : id!
                gardenGuideViewController.email = email //result.user.email!
                gardenGuideViewController.provider = provider
                
                gardenGuideTabBarController.viewControllers?[0] = gardenGuideViewController
                
                self.view.window?.windowScene?.keyWindow?.rootViewController = gardenGuideTabBarController
                self.view.window?.windowScene?.keyWindow?.makeKeyAndVisible()
            }
            
        } else {
            let alertController = UIAlertController(title: "Error", message: "An error occurred while registering the user", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Accept", style: .default)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }
    }
    
    
}

extension AuthMainViewController: AuthMainViewProtocol {
    func verifyAuthentication(result: AuthDataResult?, error: Error?, provider: ProviderType, id: String?) {
        goToGardenGuideViewController(result: result, error: error, provider: provider, id: id)
    }
}
