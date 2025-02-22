//
//  SettingsViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 18/01/25.
//

import UIKit
import FirebaseAuth

//MARK: Protocol to Delegate
protocol SettingsViewControllerDelegate: AnyObject {
    func deletingCellsFromThePlantGarden(_ isEditingMode: Bool)
    func updateVariables()
}

class SettingsViewController: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var borrarboton: UIButton!
    @IBOutlet weak var editGardenPlantsSwitch: UISwitch!
    
    
    //MARK: general variables
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
    
    //MARK: Enums
    //options for the log view
    enum LogViewStatus {
        case show
        case hide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUISheetPresentationController()
        configTextFields()
        editGardenPlantsSwitch.isOn = isEditingMode
        logViewStatus = .hide
        controller.obtainUserInformation()
        signOutButton.modifyCornerRadius(signOutButton.frame.height / 3)
        NotificationCenter.default.addObserver(self, selector: #selector(getUsetAnonymously), name: Notifications.userAnonymouslyNotification, object: nil)
    }

    
    //MARK: General methods

    func configUISheetPresentationController() {
        //Determine the form the type of presentation that the viewController will have
        guard let presentationController = presentationController as? UISheetPresentationController else {return}
        presentationController.detents = [.medium()]
        presentationController.selectedDetentIdentifier = .large
        presentationController.prefersGrabberVisible = true
        presentationController.preferredCornerRadius = 30
    }
    
    private func configTextFields() {
        let textFields: [UITextField] = [passwordTextField, emailTextField]
        textFields.forEach { textField in
            textField.autocorrectionType = .no
            textField.textContentType = .oneTimeCode
            textField.inputView = nil
            textField.inputAccessoryView = nil
            textField.spellCheckingType = .no
        }
    }
    
    //update the log view based on the selected status
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
    
    //enable or disable textFields-based signUpButtons
    private func isEnablesignUpButton() {
        guard emailTextField.text != "" && passwordTextField.text != "" else {
            signUpButton.isEnabled = false
            return
        }
        signUpButton.isEnabled = true
    }
    
    //close the user's session
    private func willTheLogoutSessionBeClosed() {
        saveDataOnFirestore { [self] in
            //close sesion in Firebase
            firabaseLogOut()
            //remove email and provider
            removeUser()
            firestoreUtilts.modifyUserEmail("")
            firestoreUtilts.modifyUserProvider(ProviderType.none.rawValue)
            //remove CoreData
            let dataManager = CoreDataPlant()
            dataManager.deletePlants()
            delegate?.updateVariables()
            //Go to Storyboard without authentication
            let authStoryboard = UIStoryboard(name: "AuthMain", bundle: .main)
            if let authMainViewController = authStoryboard.instantiateViewController(withIdentifier: "AuthMainVC") as? AuthMainViewController {
                authMainViewController.modalPresentationStyle = .fullScreen
               present(authMainViewController, animated: true)
            }
        }
    }
    
    private func obtainTitlesToSendMessageToUser(providerType: ProviderType, email: String) -> [String:String] {
        let title = providerType == .anonymous ? "You registered anonymously, are you sure you want to log out?" : "Sure you want to log out?"
        let subTitle = providerType == .anonymous ? "If you close the section, your data will be deleted." : "You are logged in with the account: \(email)"
        let titleAction = "Add a new account and save the data"
        
        let titles: [String:String] = ["title": title, "subTitle": subTitle, "titleAction":titleAction]
        return titles
    }
    
    //alert Controller to close the user's session
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
    
    
    //MARK: ViewController Actions
    
    //delete or not the gardenPlants selected in UserGardenView
    @IBAction func removeAnyPlantsInYourGarden(_ sender: UISwitch) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.delegate?.deletingCellsFromThePlantGarden(sender.isOn)
            self?.dismiss(animated: true)
        }
    }
    
    //update the email with EmailTextField
    @IBAction func editingEmailTextField(_ sender: UITextField) {
        isEnablesignUpButton()
        guard let email = sender.text, email.isValidEmail else {
            newEmail = nil
            return
        }
        self.newEmail = email
    }
    
    //update the password with EmailTextField
    @IBAction func editingPasswordTextField(_ sender: UITextField) {
        password = String(passwordSafeString: sender.text ?? "")
        isEnablesignUpButton()
    }
    
    //action to log out
    @IBAction func signOut(_ sender: UIButton) {
        let titles = obtainTitlesToSendMessageToUser(providerType: providerType, email: email)
        sendMessageToUser(titles: titles, providerType: providerType, sender: sender)
    }
    
    //action to sign Up
    @IBAction func signUp(_ sender: UIButton) {
        //veriry if email and password are correct
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
        //try to sign Up with Firestores
        controller.signUpWithEmail(email, password: password, user: Notifications.shared.user, uid: self.email)
    }
    
    // Get anonymously user
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
        print("saved user")
    }
    
    //Delete the user's information
    func removeUser() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "provider")
        defaults.synchronize()
        print("User deleted")
    }
    
  
    
    
    
    //MARK: Firestore Methods
    private func saveDataOnFirestore(completion: @escaping () -> Void )  {
        Task {
            //check if user is not anonymously
            await makeMethodsForFirestoreCloud {
                //get plants in CoreData
                let dataManager = CoreDataPlant()
                let plantsEntity = dataManager.fetchPlants()
                for index in 0 ..< plantsEntity.count {
                    //check if plant is added
                    guard plantsEntity[index].isAdded  else { continue }
                    let plantEntity = plantsEntity[index]
                    let watered = dataManager.fetchWatered(plant: plantEntity)
                    
                    guard watered?.numberOfDays != -1 || watered?.waterAmount != 0 else {
                        //Save the favouritePlant on Firestore Cloud
                        await self.saveFavouritePlantOnFirestore(plantEntity, dataManager: dataManager)
                        continue
                    }
                    //Save the gardenPlant on Firestore Cloud
                    await self.saveGardenPlantOnFirestore(plantEntity, dataManager: dataManager)
                    continue
                }
            }
            completion()
        }
    }
    
    //Log Out on firabase
    private func firabaseLogOut() {
        /*if providerType == .email {
            GIDSignIn.sharedInstance.signOut()
        }
        */
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            print("user log out")
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    private func saveFavouritePlantOnFirestore(_ plant: PlantEntity, dataManager: CoreDataPlant) async {
        //get data
        let detailsEntity = dataManager.fetchPlantDetails(plant: plant)
        let name = plant.name
        let max: Int = Int(detailsEntity?.wateringMax ?? 1)
        let min: Int = Int(detailsEntity?.wateringMin ?? 1)
        let image = detailsEntity?.descriptionImageUrl ?? Constants.imagePlant
        let favouritePlant = FavouritePlant(name: name!, image: image, min: min, max: max)
        //save Data
        await FirestoreAddData.shared.addPlantOfFavouritesToCloud(favouritePlant)
    }
    
    private func saveGardenPlantOnFirestore(_ plant: PlantEntity, dataManager: CoreDataPlant) async {
        //get data
        let planInformation = convertPlantEntityModelPlantInformation(plant, dataManager: dataManager)
        guard let watered = dataManager.fetchWatered(plant: plant) else {return}
        let irrigationInformation = IrrigationInformation(numberOfDays: watered.numberOfDays, waterAmount: watered.waterAmount, percentage: watered.percentage, wasItWatered: watered.wasItWatered, nextIrrigation: (watered.nextIrrigation)!)
        let plantForFirestore = FirestoreUtilts.shared.plantInformationModelToPlantForFirestoreModel(planInformation, watered: irrigationInformation)
        //save data
        await FirestoreAddData.shared.addGardenPlantToCloud(plantForFirestore)
    }
    
    private func convertPlantEntityModelPlantInformation(_ plantEntity: PlantEntity, dataManager: CoreDataPlant) -> PlantInformation{
        //Get a  [SimilarImage]
        let similarImagesEntity = dataManager.fetchSimilarImages(plant: plantEntity)
        var similarImages = [SimilarImage]()
        similarImagesEntity.forEach { similarImageEntity in
            let similarImage = SimilarImage(id: similarImageEntity.id!, url: similarImageEntity.url!, similarity: similarImageEntity.similarity, image: similarImageEntity.image)
            similarImages.append(similarImage)
        }
        
        //Get different [String]?  features
        let detailsEntity = dataManager.fetchPlantDetails(plant: plantEntity)
        let commonNames = dataManager.fetchCommonNames(plantDetails: detailsEntity!)
        let synonyms = dataManager.fetchSynonyms(plantDetails: detailsEntity!)
        let edibleParts = dataManager.fetchEdibleParts(plantDetails: detailsEntity!)
        let propagationMethods = dataManager.fetchPropagationMethods(plantDetails: detailsEntity!)
        let wateredDetails = Watered(max: Int(detailsEntity!.wateringMax), min: Int(detailsEntity!.wateringMin))
        
        //Get different description values
        let description = detailsEntity?.descriptionUrl == nil ? nil : PlantDetails.Description(value: (detailsEntity?.descriptionValue)! , url: (detailsEntity?.descriptionUrl)!)
        let descriptionImage = detailsEntity?.descriptionImageUrl == nil ? nil : PlantDetails.DescriptionImage(url: (detailsEntity?.descriptionImageUrl)!, image: detailsEntity?.escriptionImage)
        
        //initialize a  PlantDetails
        let plantDetails = PlantDetails(commonNames: commonNames, url: detailsEntity?.url, rank: detailsEntity?.rank, description: description, synonyms: synonyms, image: descriptionImage, edibleParts: edibleParts, watering: wateredDetails, propagationMethods: propagationMethods)
        let plantInformation = PlantInformation(name: plantEntity.name!, isAdded: true, similarImages: similarImages, details: plantDetails)
        
        return plantInformation
    }

    
}

//MARK: Extension of SettingsController
extension SettingsViewController: SettingsControllerDelegate {
    //In case of successful authentication
    func successfulAuthentication(provider: ProviderType, email: String) {
        removeUser()
        saveUser(email: email, provider: provider)
        configUser()
        emailTextField.text = ""
        passwordTextField.text = ""
        logViewStatus = .hide
        sendSavedUserMessage(email: email, providerType: provider, sender: self.view)
        saveDataOnFirestore {
            print("user save")
        }
    }
    
    //In case of failed authentication
    func failedAuthentication(error: String) {
        errorLabel.isHidden = false
        errorLabel.text = error
    }
    
    func userInformationWasObtained(providerType: ProviderType, email: String) {
        self.providerType = providerType
        self.email = email
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
    
}








