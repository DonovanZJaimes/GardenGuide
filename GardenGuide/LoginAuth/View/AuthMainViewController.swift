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

    //MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var anonymousButton: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    //MARK: general variables
    lazy var delegate = AuthMainController(delegate: self, viewController: self)
    var password: String? = nil
    var email: String? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configEmailButtons()
        configTextFields()
        enableEmailButtons()
        errorLabel.isHidden = true
        remoteConfigWithFirebase()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        password = nil
        email = nil
        errorLabel.isHidden = true
    }
    
    //MARK: General methods
    
    //Config View
    private func configEmailButtons() {
        let emailButtons = [logInButton, signUpButton]
        emailButtons.forEach { button in
            button?.modifyCornerRadius((button?.frame.height)!/7)
        }
        let signInButtons =  [googleButton, twitterButton]
        signInButtons.forEach { button in
            button?.modifyCornerRadius((button?.frame.height)!/7, withColor: .opaqueGray, andWidth: 0.3)
        }
    }
    
    private func configTextFields() {
        let textFields: [UITextField] = [passwordTextField, emailTextField]
        textFields.forEach { textField in
            textField.autocorrectionType = .no
            textField.inputView = nil
            textField.inputAccessoryView = nil
            textField.spellCheckingType = .no
        }
        passwordTextField.textContentType = .oneTimeCode
        
    }
    
    func goToGardenGuideViewController(email: String, provider: ProviderType) {
        let gardenGuideStoryboard = UIStoryboard(name: "GardenGuide", bundle: .main)
        if let gardenGuideTabBarController = gardenGuideStoryboard.instantiateViewController(withIdentifier: "GardenGuideTBC") as? UITabBarController,
           let gardenGuideNavigationController = gardenGuideStoryboard.instantiateViewController(withIdentifier: "GardenGuideNC") as? UINavigationController,
           let gardenGuideViewController = gardenGuideNavigationController.viewControllers.first as? GardenGuideViewController,
           let userGardenNavigationController = gardenGuideStoryboard.instantiateViewController(withIdentifier: "UserGardenNC") as? UINavigationController {
            
            gardenGuideViewController.email = email
            gardenGuideViewController.provider = provider
            
            gardenGuideTabBarController.setViewControllers([gardenGuideNavigationController, userGardenNavigationController], animated: false)
            
            self.view.window?.windowScene?.keyWindow?.rootViewController = gardenGuideTabBarController
            self.view.window?.windowScene?.keyWindow?.makeKeyAndVisible()
        }
        
    }
    
    func remoteConfigWithFirebase(){
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 60
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(["show_Sign_In_Button": NSNumber(true), "error_Button_text":NSString("MuestrameError"), "show_error_button":NSNumber(true)])
        //present or hide the button
        remoteConfig.fetchAndActivate{ (status, error) in
            if status != .error {
                let showSignInButton = remoteConfig.configValue(forKey: "show_Sign_In_Button").boolValue
                
                DispatchQueue.main.async {
                    self.signInButton.isHidden = !showSignInButton
                }
            }
        }
    }
    
    
    //MARK: Email Auth
    @IBAction func logInButtonAction(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text  {
            delegate.signInWithEmail(email, password: password)
        }
    }
    
    @IBAction func signUpButtonAction(_ sender: Any) {
        guard let email = email else {
            errorLabel.isHidden = false
            errorLabel.text = SignUpError.invalidEmail.localizedDescription
            return
        }
        guard let password = password  else {
            errorLabel.isHidden = false
            errorLabel.text = SignUpError.invalidPassword.localizedDescription
            return
        }
         
        errorLabel.isHidden = true
        delegate.signUpWithEmail( email, password: password)
    }
    
    
   //MARK: Google Auth
    @IBAction func signInWithGIDGoogle(_ sender: GIDSignInButton) {
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
                if let result = result, error == nil {
                    self.goToGardenGuideViewController(email: (result.user.email ?? result.user.displayName) ??  "" , provider: .google)
                }else {
                    self.errorLabel.text = "Failed Authentication"
                }
            }
        }
    }
    
    //MARK: Google Auth
    @IBAction func signInWithGoogle(_ sender: UIButton) {
        delegate.signInWithGoogle()
    }
    
    //MARK: Anonymous Auth
    @IBAction func signUpAnonymously(_ sender: Any) {
        delegate.signUpAnonymously()
    }
    
    //MARK: Twitter Auth
    @IBAction func twitterButtonAction(_ sender: Any) {
        delegate.signInWithTwitter()
    }
    
    //MARK: Actions
    @IBAction func editingEmailTextField(_ sender: UITextField) {
        enableEmailButtons()
        guard let email = sender.text, email.isValidEmail else {
            email = nil
            return
        }
        self.email = email
    }
    
    @IBAction func editingPasswordTextField(_ sender: UITextField) {
        password = String(passwordSafeString: sender.text ?? "")
        enableEmailButtons()
    }
    
    private func enableEmailButtons() {
        guard emailTextField.text != "" && passwordTextField.text != "" else {
            signUpButton.isEnabled = false
            logInButton.isEnabled = false
            return
        }
        signUpButton.isEnabled = true
        logInButton.isEnabled = true
        
    }
    
    
    
}

//MARK: Extension of AuthMainController
extension AuthMainViewController: AuthMainViewProtocol {
    func sendUser(_ user: User) {
        Notifications.shared.user = user
    }
    
    func successfulAuthentication(provider: ProviderType, email: String) {
        errorLabel.isHidden = true
        goToGardenGuideViewController(email: email, provider: provider)
    }
    
    func failedAuthentication(error: String) {
        errorLabel.isHidden = false
        errorLabel.text = error
    }
    
}
