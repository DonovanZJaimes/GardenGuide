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

    //MARK: Outlets
    @IBOutlet weak var closeSessionButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var plantsSearchBar: UISearchBar!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var lookForPlantsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plantBackgroundView: UIView!
    @IBOutlet weak var heightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var heightPlantBackgroundView: NSLayoutConstraint!
    @IBOutlet weak var cameraMeteringImageView: UIImageView!
    @IBOutlet weak var plantBackgroundViewButton: UIButton!
    @IBOutlet weak var plantsCollectionView: CollectionTabsView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    @IBOutlet weak var SearchBarButton: UIButton!
    
    //MARK: general Enums
    //ImagePicker selected image view states
    enum ViewStateVisibility {
        case show
        case hide
    }
    
    //Image used for ImagePicker
    enum SelectImageFor {
        case plant
        case user
    }
    
    //MARK: general variables
    var email: String = ""
    var provider: ProviderType = .none
    //var user: User? = nil
    var currentSelectedImage = SelectImageFor.plant
    //Controller for de ViewController
    lazy var controller = SearchViewController(delegate: self)
    //SearchController for de ViewController
    let searchController = UISearchController(searchResultsController: PlantSearchListViewController())
    //Plants for the tableView
    var randomPlants: [SuggestedPlant] = []
    //CoreData
    let dataManager = CoreDataPlant()
    let defaults = UserDefaults.standard
    //Cloud Firestore
    private let db = Firestore.firestore()
    private var firestoreUtilts = FirestoreUtilts()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUser()
        setUpView()
        plantBackgroundViewVisibility(.hide)
        setUpTableView()
        collectionViewVisibility(.hide)
        setupSearchController()
        updateTheTableViewData()
        remoteConfigWithFirebase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //Change the height of the table view
        if keyPath == "contentSize"{
            if object is UITableView{
                if let newValue = change?[.newKey] {
                    let newSize = newValue as! CGSize
                    self.heightTableView.constant = newSize.height
                }
            }
        }
    }
    
    
    //MARK: UserDefaults Methods
    //Configure user values
    func configUser(){
        //getting information from defaults
        if let email = defaults.value(forKey: "email") as? String, let provider = defaults.value(forKey: "provider") as? String, let providerType = ProviderType.init(rawValue: provider) {
            self.email = email
            self.provider =  providerType
            //print("User with email: " + email + "and provider: " + provider)
        }
        //save data
        saveUser(email: email, provider: provider)
        firestoreUtilts.modifyUserEmail(email)
        firestoreUtilts.modifyUserProvider(provider.rawValue)
        //save user on Firestore Cloud
        Task {
            await controller.saveUserToFirestoreCloud(email: email, provider: provider.rawValue)
        }
    }
    
    //Save the values of the information
    func saveUser(email: String, provider: ProviderType) {
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(provider.rawValue, forKey: "provider")
        defaults.synchronize()
        print("User saved.  User with email: " + email + "and provider: " + provider.rawValue)
    }
    
    
    //MARK: General methods
    
    //Modify the radio and border of images and buttons
    func setUpView() {
        //Buttons
        lookForPlantsButton.modifyCornerRadius(lookForPlantsButton.frame.height / 3)
        //Images
        backgroundImageView.layer.cornerRadius = backgroundImageView.frame.width / 15
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        let borderColor: UIColor = .customDarkGreen
        userImageView.layer.borderColor = borderColor.cgColor
        userImageView.layer.borderWidth = 1.5
        //Modify color of tabBarItem
        tabBarController?.tabBar.tintColor = .customGreen
    }
    
    //Modify the visibility of a background view
    func plantBackgroundViewVisibility(_ state: ViewStateVisibility) {
        //Hide or show the view that contains the image plant to search for more similar plants
        switch state {
        case .show:
            plantBackgroundView.isHidden = false
            heightPlantBackgroundView.constant = 200
        case .hide:
            plantBackgroundView.isHidden = true
            heightPlantBackgroundView.constant = 0.0
        }
    }
    
    //Set Up TableView
    func setUpTableView() {
        //Delegate and Data Sourse
        tableView.delegate = self
        tableView.dataSource = self
        
        //Register Cell
        tableView.register(UINib(nibName: "\(RandomPlantsTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(RandomPlantsTableViewCell.self)")
        
        //Register Header View
        tableView.register(SectionTitleView.self, forHeaderFooterViewReuseIdentifier: "\(SectionTitleView.self)")
        
        //Others
        tableView.separatorColor = .clear
    }
    
    //Hide or show the collectionView
    func collectionViewVisibility(_ state: ViewStateVisibility) {
        switch state {
        case .show:
            plantsCollectionView.isHidden = false
            heightCollectionView.constant = 280.0
        case .hide:
            heightCollectionView.constant = 0.0
            plantsCollectionView.isHidden = true
        }
    }
    
    //set up SearchController
    func setupSearchController() {
        //Config searchController
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        //Config searchBar
        searchController.searchBar.placeholder = "Search Plants"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.isHidden = true
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.keyboardType = .default
        searchController.searchBar.spellCheckingType = .no
        
        // Customize the color of the “Cancel” button
        let cancelButtonAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.customGreen // Change the color here
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        
    }
    
    //update TableView view
    func updateTheTableViewData(){
        //Get random plants from previous searches in coreData
        randomPlants = controller.getRandomPlants()
        if randomPlants.count == 0 {
            print("Does not have recents searches")
        } else {
            tableView.reloadData()
        }
    }
    
    //Get similar plants from the image
    private func searchForPlantsByImage(){
        let imageToBase64 = convertImageToBase64String(image: plantImageView.image!)
        Task{ [weak self] in
            //get plants
            await self?.controller.getPlantsByImage(imageInBase64String: imageToBase64)
        }
    }
    
    //conver an image to a base 64 string
    func convertImageToBase64String (image: UIImage) -> String {
        return image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    //AlertController to select image from camera or gallery
    private func selectImage(for state: SelectImageFor, sender: UIButton) {
        //config ImagePickerController
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        //create a AlertController
        let title = ((state == .plant ) ? "Camera or Galery" : "Galery" )
        let alertController = UIAlertController(title: title, message: "Choose one", preferredStyle: .alert)
        
        //create a AlertActions
        /**To Cancel**/
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        /**For the Camera**/
        if state == SelectImageFor.plant {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true)
                }
                alertController.addAction(cameraAction)
            }
            
        }
        /**For the Gallery**/
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true)
                
            }
            alertController.addAction(photoLibraryAction)
        }
        
        //present the alertController
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }
    
    //hide or show views to display the searchController
    private func prepareViewForSearchController(isActive: Bool) {
        searchController.searchBar.isHidden.toggle()
        switch isActive {
        case true:
            greetingLabel.alpha = 0.0
            userImageView.alpha = 0.0
            plantsSearchBar.alpha = 0.0
            cameraButton.alpha = 0.0
        case false:
            greetingLabel.alpha = 1.0
            userImageView.alpha = 1.0
            plantsSearchBar.alpha = 1.0
            cameraButton.alpha = 1.0
        }
    }
    
    //MARK: Firebase Methods
   
    //test FirebaseRemoteConfig with one button
    private func remoteConfigWithFirebase() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 60
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(["show_error_button":NSNumber(true)])
        // hide or show the button
        remoteConfig.fetchAndActivate{ (status, error) in
            if status != .error {
                let showErrorButton = remoteConfig.configValue(forKey: "show_error_button").boolValue
                
                DispatchQueue.main.async {
                    self.closeSessionButton.isHidden = !showErrorButton
                }
            }
        }
    }
    
    
    //MARK: ViewController @IBActions
    
    //config action with FirebaseRemoteConfig
    @IBAction func closeSession(_ sender: Any) {
        print("TEST 3 WITH FirebaseRemoteConfig")
        print("Button displayed with FirebaseRemoteConfig")
    }
    
    @IBAction func closePlantBackgroundView(_ sender: UIButton) {
        plantBackgroundViewVisibility(.hide)
    }
    
    //select user image with ImagePicker
    @IBAction func userButtonTapped(_ sender: UIButton) {
        currentSelectedImage = .user
        selectImage(for: .user, sender: sender)
    }
    
    //present image plant with imagePicker
    @IBAction func lookForPlantsButtonTapped(_ sender: UIButton) {
        collectionViewVisibility(.show)
        //search results with API or Mock
        searchForPlantsByImage()
    }
    
    //select plant image with ImagePicker
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        currentSelectedImage = .plant
        selectImage(for: .plant, sender: sender)
    }
    
    //active SearchController
    @IBAction func searchForSomethingWithSearchController(_ sender: Any) {
        // Simulates the user pressing the search button
        if !searchController.isActive {
            searchController.isActive = true
        }
        DispatchQueue.main.async {
            self.searchController.searchBar.becomeFirstResponder()
        }
        prepareViewForSearchController(isActive: true)
    }
}


//MARK: Extension of ImagePickerController
extension GardenGuideViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //select image
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        //Placing the selected image on the user or the plant
        switch currentSelectedImage {
        case .plant:
            plantImageView.image = image
            plantBackgroundViewVisibility(.show)
        case .user:
            userImageView.image = image
        }
        dismiss(animated: true)
    }
}


//MARK: Extension of CollectionTabsViewDelegate
extension GardenGuideViewController: CollectionTabsViewDelegate {
    func savePlantMessage(_ text: String, sender: UIButton) {
        sendMessageToUser(sender, text: text)
    }
    
    func didSelectPlant(index: Int) {
        //Display the plant selected on PlantDetailsViewController
        let vc = PlantDetailsViewController()
        vc.suggestedPlant = controller.plantResults.suggestedPlants[index]
        present(vc, animated: true)
    }
    
    //create and present the AlertController
    func sendMessageToUser(_ sender: UIButton, text: String) {
        //create
        let alertController = UIAlertController(title: "The plant is already saved", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(cancelAction)
        //present
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }
}


//MARK: Extension of SearchViewControllerDelegate
extension GardenGuideViewController: SearchViewControllerDelegate {
    //Display the plants in CollectionView
    func getPlantsResultsPerImage() {
        guard  let plants = controller.plantResults else {
            return
        }
        plantsCollectionView.isHidden = false
        plantsCollectionView.buildView(delegate: self, plants: plants)
        savePlantsInCoreData(plants)
    }
    
    func savePlantsInCoreData(_ plants: PlantsByImageSearch){
        guard CoreDataUtils.shared.savePlantsByImageSearch else { 
            print("New plants are not saved in the history")
            return }
        plants.suggestedPlants.forEach { suggestedPlant in
            CoreDataUtils.shared.saveNewPlant(suggestedPlant)
        }
        
    }
}


//MARK: Extension of TableViewDelegate and TableViewDataSource
extension GardenGuideViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let plants = randomPlants.count
        return plants
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get data
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(RandomPlantsTableViewCell.self)", for: indexPath) as! RandomPlantsTableViewCell
        let plant = randomPlants[indexPath.row]
        //config cell with data
        cell.configureCell(plant: plant)
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .customBackgroundColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(SectionTitleView.self)") as? SectionTitleView else {
            return nil
        }
        header.titleLabel.text = "Related Searches"
        header.configView()
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Display the plant selected on PlantDetailsViewController
        let vc = PlantDetailsViewController()
        vc.suggestedPlant = randomPlants[indexPath.row]
        present(vc, animated: true)
    }
}


//MARK: Extension SearchBar, SearchResults and SearchController
extension GardenGuideViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchString = searchController.searchBar.text,
              searchString.isEmpty == false else {
            return
        }
        //instantiate plantSearchListViewController
        let plantSearchListViewController = searchController.searchResultsController as? PlantSearchListViewController
        plantSearchListViewController?.delegate = self
        //Send the word to the method to do the search for the plants and display them in the tableView
        plantSearchListViewController?.searchListOfPlants(word: searchString)
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        //SearchController is going to be discarded
        prepareViewForSearchController(isActive: false)
    }
    
}

//MARK: Extension PlantSearchListViewControllerDelegate
extension GardenGuideViewController: PlantSearchListViewControllerDelegate {
    func plantSearchListViewController(_ controller: PlantSearchListViewController, accessToken: String, name: String) {
        searchController.searchBar.resignFirstResponder()
        //initialise and present the PlantDetailsViewController
        let vc = PlantDetailsViewController()
        vc.accessToken = accessToken
        vc.name = name
        present(vc, animated: true)
        prepareViewForSearchController(isActive: false)
    }
}

