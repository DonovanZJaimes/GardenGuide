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
    
    
    var email: String = ""
    var provider: ProviderType = .none
    var currentSelectedImage = SelectImageFor.plant
    lazy var controller = SearchViewController(delegate: self)
    var randomPlants: [SuggestedPlant] = []
    
    enum ViewStateVisibility {
        case show
        case hide
    }
    
    enum SelectImageFor {
        case plant
        case user
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(email)
        print(provider)
        saveUser(email: email, provider: provider)
        
        setUpView()
        plantBackgroundViewVisibility(.hide)
        //print(heightCollectionView.constant)
        //heightCollectionView.constant = 0.0
        //plantsCollectionView.isHidden = true
        //searchForPlantsByImage()
        setUpTableView()
        
        heightCollectionView.constant = 0.0
        plantsCollectionView.isHidden = true
        Task {
            randomPlants = try await getPlantsByImage(imageInBase64String:"")
            tableView.reloadData()
        }
        
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
        if keyPath == "contentSize"
        {
            if object is UITableView
            {
                if let newValue = change?[.newKey] {
                    let newSize = newValue as! CGSize
                    self.heightTableView.constant = newSize.height
                }
            }
        }
    }
    
    
    
    //Modify the radio and border of images and buttons
    func setUpView() {
        backgroundImageView.layer.cornerRadius = backgroundImageView.frame.width / 15
        lookForPlantsButton.modifyCornerRadius(lookForPlantsButton.frame.height / 3)
        userImageView.layer.cornerRadius = userImageView.bounds.height / 2
        let borderColor: UIColor = .customDarkGreen
        userImageView.layer.borderColor = borderColor.cgColor
        userImageView.layer.borderWidth = 1.5
    }
    
    //Modify the visibility of a background view
    func plantBackgroundViewVisibility(_ state: ViewStateVisibility) {
        switch state {
        case .show:
            plantBackgroundView.isHidden = false
            heightPlantBackgroundView.constant = 200
        case .hide:
            plantBackgroundView.isHidden = true
            heightPlantBackgroundView.constant = 0.0
        }
    }
    
    func setUpTableView() {
        //Delegate and Data Sourse
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.isHidden = false
        
        //Register Cell
        tableView.register(UINib(nibName: "\(RandomPlantsTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(RandomPlantsTableViewCell.self)")
        
        //Register Header View
        tableView.register(SectionTitleView.self, forHeaderFooterViewReuseIdentifier: "\(SectionTitleView.self)")
        
        //Others
        tableView.separatorColor = .clear
    }
    
    func getPlantsByImage(imageInBase64String: String) async throws -> [SuggestedPlant] {
        guard let model = Utils.parseJson(jsonName: "PlantResultsByImageSearch", model: SimilarPlants.self) else{
            print("No se pudo convertir")
            throw NetworkError.jsonDecoder
        }
        let suggestedPlants = model.result.classification.suggestedPlants
        return suggestedPlants
    }
    
    
    private func searchForPlantsByImage(){
        let imageToBase64 = convertImageToBase64String(image: plantImageView.image!)
        Task{ [weak self] in
            await self?.controller.getPlantsByImage(imageInBase64String: imageToBase64)
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
        /*removeUser()
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
        }*/
        //MARK: POST
        /*
        let img = convertImageToBase64String(image: plantImageView.image!)
        lab.text = "{\n    \"images\": [\"data:image/jpg;base64," + img + "\"],\n   \"similar_images\": true\n}"
        
        let parameters = "{\n    \"images\": [\"data:image/jpg;base64," + img + "\"],\n   \"similar_images\": true\n}"
        
        let postData = parameters.data(using: .utf8)

            var request = URLRequest(url: URL(string: "https://plant.id/api/v3/identification?details=common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering")!,timeoutInterval: Double.infinity)
            request.addValue("uUAV0pEcCMm8if3lJcgcpok2DzWOtaW8owfKFyrCa4FnD9yQNN", forHTTPHeaderField: "Api-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            request.httpMethod = "POST"
            request.httpBody = postData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
              guard let data = data else {
                print(String(describing: error))
                return
              }
                print("AAAAAAAAAAAAAA")
              print(String(data: data, encoding: .utf8)!)
            }

            task.resume()
*/
        
        //MARK: GET PLANTS
        
        var request5 = URLRequest(url: URL(string: "https://plant.id/api/v3/kb/plants/name_search?q=tulipa")!,timeoutInterval: Double.infinity)
        request5.addValue("uUAV0pEcCMm8if3lJcgcpok2DzWOtaW8owfKFyrCa4FnD9yQNN", forHTTPHeaderField: "Api-Key")
        request5.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request5.httpMethod = "GET"

        let task5 = URLSession.shared.dataTask(with: request5) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
            print("BBBBBBBBBB")
          print(String(data: data, encoding: .utf8)!)
        }

        task5.resume()
        
        
    //MARK: GET DETAIL
        /*
        var request = URLRequest(url: URL(string: "https://plant.id/api/v3/kb/plants/XGhdakFxY1pPeHNHMVRSM1xkQHZWYwoyU2RNelAyTXk-?details=common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering,propagation_methods")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("uUAV0pEcCMm8if3lJcgcpok2DzWOtaW8owfKFyrCa4FnD9yQNN", forHTTPHeaderField: "Api-Key")

         
         
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            return
          }
            print("CCCCCCCCCCCCCCCCCCC")
          print(String(data: data, encoding: .utf8)!)
        }

        task.resume()

        */
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
    
    
    //MARK: IBActions
    @IBAction func closePlantBackgroundView(_ sender: UIButton) {
        plantBackgroundViewVisibility(.hide)
    }
    
    @IBAction func userButtonTapped(_ sender: UIButton) {
        currentSelectedImage = .user
        selectImage(for: .user, sender: sender)
    }
    
    @IBAction func lookForPlantsButtonTapped(_ sender: UIButton) {
        plantsCollectionView.isHidden = false
        heightCollectionView.constant = 280.0
        searchForPlantsByImage()
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        currentSelectedImage = .plant
        selectImage(for: .plant, sender: sender)
    }
    
    func selectImage(for state: SelectImageFor, sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let title = ((state == .plant ) ? "Camera or Galery" : "Galery" )
        let alertController = UIAlertController(title: title, message: "Choose one", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        if state == SelectImageFor.plant {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                    imagePicker.sourceType = .camera
                    self.present(imagePicker, animated: true)
                }
                alertController.addAction(cameraAction)
            }
            
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true)
                
            }
            alertController.addAction(photoLibraryAction)
        }
        
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
        
    }
    
}

//MARK: Extension ImagePickerController
extension GardenGuideViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        switch currentSelectedImage {
        case .plant:
            plantImageView.image = image
            plantBackgroundViewVisibility(.show)
        case .user:
            userImageView.image = image
        }
        dismiss(animated: true)    }
    
    func convertImageToBase64String (image: UIImage) -> String {
        return image.jpegData(compressionQuality: 1)?.base64EncodedString() ?? ""
    }
    
    
}
//MARK: Extension CollectionTabsViewDelegate
extension GardenGuideViewController: CollectionTabsViewDelegate {
    func didSelectPlant(index: Int) {
        print("WWW",index)
    }
}

extension GardenGuideViewController: SearchViewControllerDelegate {
    func getPlantsResultsPerImage() {
        guard  let plants = controller.plantResults else {
            return
        }
        //print(plants)
        //heightCollectionView.constant = 280.0
        plantsCollectionView.isHidden = false
        plantsCollectionView.buildView(delegate: self, plants: plants)
    }
    
    
}
//MARK: Extension TableViewDelegate and TableViewDataSource
extension GardenGuideViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        randomPlants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(RandomPlantsTableViewCell.self)", for: indexPath) as! RandomPlantsTableViewCell
        let plant = randomPlants[indexPath.row]
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
        print("EEEE",indexPath)
    }
    
    
    
}
/*
 
 //@IBOutlet weak var errorButton: UIButton!
 //@IBOutlet weak var infoLabel: UITextField!
 private let db = Firestore.firestore()
 
 override func viewDidLoad() {
     super.viewDidLoad()
     print(email)
     print(provider)
     saveUser(email: email, provider: provider)
     
     /*let remoteConfig = RemoteConfig.remoteConfig()
     remoteConfig.fetchAndActivate{ (status, error) in
         if status != .error {
             let showErrorButton = remoteConfig.configValue(forKey: "show_error_button").boolValue
             let errorButtonText = remoteConfig.configValue(forKey: "error_Button_text").stringValue
             
             DispatchQueue.main.async {
                 self.errorButton.isHidden = !showErrorButton
                 self.errorButton.setTitle(errorButtonText, for: .normal)
             }
             
         }
         
     }*/
     
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
 */
