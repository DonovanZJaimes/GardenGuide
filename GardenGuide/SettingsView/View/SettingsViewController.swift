//
//  SettingsViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 18/01/25.
//

import UIKit
import FirebaseAuth

protocol SettingsViewControllerDelegate: AnyObject {
    func deletingCellsFromThePlantGarden(_ isEditingMode: Bool)
}

class SettingsViewController: UIViewController{
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var editGardenPlantsSwitch: UISwitch!
    weak var delegate: SettingsViewControllerDelegate?
    var isEditingMode = false
    lazy var controller = SettingsController(delegate: self)
    var providerType: ProviderType!
    var email: String!
    var password: String? = nil
    var newEmail: String? = nil
    var user: User!
    private var firestoreUtilts = FirestoreUtilts()
    var logViewStatus: LogViewStatus = .hide {
        willSet {
            configureSignUpView(state: newValue)
        }
    }
    
    enum LogViewStatus {
        case show
        case hide
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUISheetPresentationController()
        editGardenPlantsSwitch.isOn = isEditingMode
        logViewStatus = .hide
        controller.obtainUserInformation()
        signOutButton.modifyCornerRadius(signOutButton.frame.height / 3)
        NotificationCenter.default.addObserver(self, selector: #selector(getUsetAnonymously), name: Notifications.userAnonymouslyNotification, object: nil)
    }


    func configUISheetPresentationController() {
        //Determine the form the type of presentation that the viewController will have
        guard let presentationController = presentationController as? UISheetPresentationController else {return}
        presentationController.detents = [.medium()]
        presentationController.selectedDetentIdentifier = .large
        presentationController.prefersGrabberVisible = true
        presentationController.preferredCornerRadius = 30
    }
    
    
    @IBAction func removeAnyPlantsInYourGarden(_ sender: UISwitch) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.delegate?.deletingCellsFromThePlantGarden(sender.isOn)
            self?.dismiss(animated: true)
        }
        
    }
    
    func configureSignUpView(state: LogViewStatus) {
        switch state {
        case .show:
            signUpView.isHidden = false
            signUpViewHeight.constant = 219
            errorLabel.isHidden = true
            signUpButton.modifyCornerRadius(signUpButton.frame.height / 2)
            bottomLineView.isHidden = false
        case .hide:
            signUpView.isHidden = true
            signUpViewHeight.constant = 0
            bottomLineView.isHidden = true
        }
    }
    
    
    private func isEnablesignUpButton() {
        guard emailTextField.text != "" && passwordTextField.text != "" else {
            signUpButton.isEnabled = false
            return
        }
        signUpButton.isEnabled = true
    }
    
    
    @IBAction func editingEmailTextField(_ sender: UITextField) {
        isEnablesignUpButton()
        guard let email = sender.text, email.isValidEmail else {
            newEmail = nil
            return
        }
        self.newEmail = email
        
    }
    
    
    @IBAction func editingPasswordTextField(_ sender: UITextField) {
        password = String(passwordSafeString: sender.text ?? "")
        isEnablesignUpButton()
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        print("user with email: \(email), and provider: \(providerType.rawValue)")
        let titles = obtainTitlesToSendMessageToUser(providerType: providerType, email: email)
        sendMessageToUser(titles: titles, providerType: providerType, sender: sender)
    }
    
    
    @IBAction func signUp(_ sender: UIButton) {
        print("tratar de registrarse")
        guard let email = newEmail else {
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
        controller.signUpWithEmail(email, password: password, user: Notifications.shared.user, uid: self.email)
    }
    
    
    private func obtainTitlesToSendMessageToUser(providerType: ProviderType, email: String) -> [String:String] {
        let title = providerType == .anonymous ? "You registered anonymously, are you sure you want to log out?" : "Sure you want to log out?"
        let subTitle = providerType == .anonymous ? "If you close the section, your data will be deleted." : "You are logged in with the account: \(email)"
        let titleAction = "Add a new account and save the data"
        
        var titles: [String:String] = ["title": title, "subTitle": subTitle, "titleAction":titleAction]
        return titles
    }
    
    private func sendMessageToUser(titles: [String:String], providerType: ProviderType, sender: UIButton){
        //create alertController
        let alertController = UIAlertController(title: titles["title"], message: titles["subTitle"], preferredStyle: .alert)
        
        //create alertActions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let signOutAction = UIAlertAction(title: "Yes, close it", style: .default) { action in
            self.willTheLogoutSessionBeClosed()
        }
        if providerType == .anonymous {
            let signUpAction = UIAlertAction(title: titles["titleAction"], style: .default) { action in
                self.logViewStatus = .show
            }
            alertController.addAction(signUpAction)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(signOutAction)
        
        //present alert Controller
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
        
    }
    
    private func willTheLogoutSessionBeClosed() {
       print("cerramo sesion")
        //remove email and provider
        removeUser()
        firestoreUtilts.modifyUserEmail("")
        firestoreUtilts.modifyUserProvider(ProviderType.none.rawValue)
        //remove CoreData
        let dataManager = CoreDataPlant()
        dataManager.deletePlants()
        //Go to Storyboard without authentication
        let authStoryboard = UIStoryboard(name: "AuthMain", bundle: .main)
        if let authMainViewController = authStoryboard.instantiateViewController(withIdentifier: "AuthMainVC") as? AuthMainViewController {
            authMainViewController.modalPresentationStyle = .fullScreen
           present(authMainViewController, animated: true)
        }
        
    }
    
    @objc func getUsetAnonymously(){
        let user = Notifications.shared.user
        guard let user = user else {return}
        self.user = user
        
        
    }
    
    
    
    
    
    //MARK: UserDefaults Methods
    //Configure user values
    func configUser(){
        let defaults = UserDefaults.standard
        //getting information from defaults
        if let email = defaults.value(forKey: "email") as? String, let provider = defaults.value(forKey: "provider") as? String, let providerType = ProviderType.init(rawValue: provider) {
            self.email = email
            self.providerType =  providerType
            firestoreUtilts.modifyUserEmail(email)
            firestoreUtilts.modifyUserProvider(provider)
            print("User with email: " + email + "and provider: " + provider)
        }
       
        //save user on Firestore Cloud
        Task {
            await controller.saveUserToFirestoreCloud(email: email, provider: providerType.rawValue)
        }
    }
    //Save the values of the information
    func saveUser(email: String, provider: ProviderType) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        defaults.synchronize()
        print("usuario guardado")
    }
    
    //Delete the user's information
    func removeUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "provider")
        defaults.synchronize()
        print("usuario eliminado")
    }
    
    
    
}

extension SettingsViewController: SettingsControllerDelegate {
    func successfulAuthentication(provider: ProviderType, email: String) {
        removeUser()
        saveUser(email: email, provider: provider)
        configUser()
        emailTextField.text = ""
        passwordTextField.text = ""
        logViewStatus = .hide
        sendSavedUserMessage(email: email, providerType: provider, sender: self.view)
    }
    
    private func sendSavedUserMessage(email: String, providerType: ProviderType, sender: UIView){
        //create alertController
        let title =  "Your new account is from: \(providerType.rawValue), with the user: \(email)"
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        //create alertActions
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(cancelAction)
        
        //present alert Controller
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
        
    }
    
    func failedAuthentication(error: String) {
        errorLabel.isHidden = false
        errorLabel.text = error
    }
    
    func userInformationWasObtained(providerType: ProviderType, email: String) {
        self.providerType = providerType
        self.email = email
    }
    
    
}








