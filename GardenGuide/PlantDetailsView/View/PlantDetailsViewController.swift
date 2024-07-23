//
//  PlantDetailsViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 25/05/24.
//


import UIKit
import Kingfisher
import SafariServices
//import CoreData

class PlantDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var miniPlantImageOne: UIImageView!
    @IBOutlet weak var miniPlantImageTwo: UIImageView!
    @IBOutlet weak var miniPlantImageThree: UIImageView!
    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var plantButtonOne: UIButton!
    @IBOutlet weak var plantButtonTwo: UIButton!
    @IBOutlet weak var plantButtonThree: UIButton!
    @IBOutlet weak var plantWateringViewHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonsIconListView: ButtonIconList!
    
    //MARK: general variables
    var plantInformation: PlantInformation!
    var name: String?
    var accessToken: String?
    var suggestedPlant: SuggestedPlant?
    //var numberOfImages = 1
    var hasWatered: Bool = false
    let dataManager = CoreDataPlant()
    //Controller for de ViewController
    lazy var controller = PlantDetailsController(delegate: self)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPlantInformation()
        configView()
        configWateredView()
        configHorizontalButtons()
    }
    
    //MARK: General methods
    
    //Get information for ViewController
    func getPlantInformation() {
        //There are two forms and the controller is used to obtain it
        if let suggestedPlant = suggestedPlant {
            controller.getPlantInformationWithSuggestedPlant(suggestedPlant)
        } else {
            Task {
                await controller.getPlantInformation(accessToken: accessToken!, name: name!)
            }
        }
    }
    
    // General settings for view
    func configView() {
        //corner radius
        heartButton.modifyCornerRadius(5)
        titleBackgroundView.layer.cornerRadius = titleBackgroundView.frame.height / 2
        let miniImages = [ miniPlantImageTwo, miniPlantImageThree]
        miniImages.forEach { image in
            image?.modifyCornerRadius(5, withColor: .customYellow, andWidth: 2)
        }
        miniPlantImageOne.modifyCornerRadius(5, withColor: .customLightGreen, andWidth: 2)
    }
    
    //General settings for watering view
    func configWateredView() {
        //hide or not
        switch hasWatered {
        case true:
            plantWateringViewHeight.constant = 120
        case false:
            plantWateringViewHeight.constant = 0
        }
        
    }
    
    //Configure ButtonIconList view
    func configHorizontalButtons(){
        //Get Information for ButtonIconList
        let options =  controller.getButtonDetailsList()
        buttonsIconListView.butonIconList = options
        buttonsIconListView.delegate = self
        //Build ButtonIconList
        buttonsIconListView.buildView()
    }
    
    
    //MARK: Methods to update the view
    //This Methods occurs only if you already have the information ready
    
    //configure viewController labels information
    func updateLabels() {
        //Update Labels
        plantNameLabel.text = plantInformation.name
        rankLabel.text = "Taxonomic rank: " + (plantInformation.details.rank ?? "")
        
        if let description = plantInformation.details.description {
            descriptionTextView.text = description.value
        } else {
            descriptionTextView.text = ""
        }
    }
    
    //configure viewController imagesView
    func updateImages() {
        //Update View Images
        
        //Get image view url
        var URLImages = [URL]()
        if let similarImages = plantInformation.similarImages {
            similarImages.forEach { similarImage in
                if let url =  URL(string: similarImage.url) {
                    URLImages.append(url)
                }
            }
        }
        if let urlString = plantInformation.details.image?.url  {
            if let url = URL(string: urlString) {
                URLImages.append(url)
            }
        }
        //Add the Images
        DispatchQueue.main.async {
            switch URLImages.count {
            case 0:
                self.plantImage.image = UIImage(named: "Plant7")
                self.miniPlantImageOne.image = UIImage(named: "Plant7")
                self.miniPlantImageTwo.isHidden = true
                self.plantButtonTwo.isHidden = true
                self.miniPlantImageThree.isHidden = true
                self.plantButtonThree.isHidden = true
            case 1:
                self.plantImage.kf.setImage(with: URLImages[0])
                self.miniPlantImageOne.image = self.plantImage.image
                self.miniPlantImageTwo.isHidden = true
                self.plantButtonTwo.isHidden = true
                self.miniPlantImageThree.isHidden = true
                self.plantButtonThree.isHidden = true
            case 2:
                self.plantImage.kf.setImage(with: URLImages[0] )
                self.miniPlantImageOne.image = self.plantImage.image
                self.miniPlantImageTwo.kf.setImage(with: URLImages[1])
                self.miniPlantImageThree.isHidden = true
                self.plantButtonThree.isHidden = true
                //self.numberOfImages = 2
            case 3:
                self.plantImage.kf.setImage(with: URLImages[0] )
                self.miniPlantImageOne.image = self.plantImage.image
                self.miniPlantImageTwo.kf.setImage(with: URLImages[1])
                self.miniPlantImageThree.kf.setImage(with: URLImages[2])
                //self.numberOfImages = 3
            default:
                return
            }
        }
    }
    
    
    //MARK: Methods to Core Data
    func savePlantCoreData() {
        //Create Plant
        plantInformation.isAdded = true
        //Save plant
        dataManager.savePlant(plant: plantInformation, watered: Constants.irrigationInformation)
        //notify that a new plant has been added
        Notifications.shared.newPlants.append(plantInformation)
    }
    
    func checkIfThePlantWillBeSaved(_ sender: UIButton) {
        let alertController = UIAlertController(title: "The plant is already saved", message: "Do you want to save again?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ action in
            // notify that a plant has been removed
            Notifications.shared.newPlants.removeLast()
        }
        alertController.addAction(cancelAction)
        
        let saveAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.savePlantCoreData()
        }
        alertController.addAction(saveAction)
        
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }
    


    //MARK: viewController actions
    
    @IBAction func heartButtonPressed(_ sender: UIButton) {
        //check button status
        sender.isSelected.toggle()
        guard sender.isSelected else {
            //if the button is no longer selected
            if let plant = dataManager.returnLastSavedPlant() {
                dataManager.deletePlant(plant)
            }
            return
        }
        //in case the button is selected
        let plants = dataManager.fetchPlants()
        var isAdded = false
        plants.forEach {
            isAdded = $0.name == plantInformation.name ? true : false
        }
        //We check if the plant was already saved previously
        guard !isAdded else {
            checkIfThePlantWillBeSaved(sender)
            return
        }
        //in case you have not saved the same plant previously
        savePlantCoreData()
    }
    

    @IBAction func readMoreButtonPressed(_ sender: UIButton) {
        //Open a safari page for more information about the plant
        /*guard let urlString = plantInformation.details.url, let url = URL(string: urlString)  else {
            sender.isEnabled = true
            return
        }
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true)
        */
        
        print("SIMPLE")
        let Plants = dataManager.fetchPlants()
        print(Plants.count)
        for index in 0 ..< Plants.count {
            print("SIGUIENTE")
            let plant = Plants[index]
            print(plant.name!)
            print(plant.isAdded)
            let details = dataManager.fetchPlantDetails(plant: plant)
            print(details!.rank!)
            let commonNames = dataManager.fetchCommonNames(plantDetails: details!)
            print(commonNames)
            let synoni = dataManager.fetchSynonyms(plantDetails: details!)
            print(synoni)
            let edibleP = dataManager.fetchEdibleParts(plantDetails: details!)
            print(edibleP)
            let propaMe = dataManager.fetchPropagationMethods(plantDetails: details!)
            print(propaMe)
            
            
            let Watered = dataManager.fetchWatered(plant: plant)
            print(Watered?.nextIrrigation)
            
            let SimilarImages = dataManager.fetchSimilarImages(plant: plant)
            print(SimilarImages.first?.url)
            
        }
     
        
    }
    
    
    @IBAction func miniPlantImagePressed(_ sender: UIButton) {
        //Variables
        let miniImages = [ miniPlantImageOne, miniPlantImageTwo, miniPlantImageThree]
        let colorYellow: UIColor = .customYellow
        let colorGreen: UIColor = .customLightGreen
        //Modify the color border of the mini images
        miniImages.forEach { image in
            image?.layer.borderColor = colorYellow.cgColor
        }
        //modify the color border of the selected mini image and change the large image to the mini image
        switch sender {
        case plantButtonOne:
            plantImage.image = miniPlantImageOne.image
            miniPlantImageOne.layer.borderColor = colorGreen.cgColor
        case plantButtonTwo:
            plantImage.image = miniPlantImageTwo.image
            miniPlantImageTwo.layer.borderColor = colorGreen.cgColor
        case plantButtonThree:
            plantImage.image = miniPlantImageThree.image
            miniPlantImageThree.layer.borderColor = colorGreen.cgColor
        default:
            return
        }
    }
    
}

//MARK: Extension for controller delegate
extension PlantDetailsViewController: PlantDetailsControllerDelegate {
    func obtainedPlantInformation() {
        //Get plant information
        self.plantInformation = controller.plantInformation
        //Update viewController information
        updateLabels()
        updateImages()
    }
    
    
}

//MARK: Extension on button press of ButtonIconList
extension PlantDetailsViewController: ButtonIconListProtocol {
    func didSelectOption(tag: Int) {
        let vc = ButtonDetailsViewController()
        //Depending on the button pressed, the ButtonDetailsViewController will be initialized
        if tag == 2 {
            vc.plantName = plantNameLabel.text
            vc.isTheViewForTheWateringButton = true
            let watered = controller.getButtonDetailsList(tag: tag)
            vc.minHumidity = Int(watered.first!)
            vc.maxHumidity = Int(watered.last!)
            //Get controller information
            vc.titleList = controller.getButtonTitle(tag: tag)
        } else {
            vc.listOfInformation = controller.getButtonDetailsList(tag: tag)
            //Get controller information
            vc.titleList = controller.getButtonTitle(tag: tag)
        }
        //Present de View
        present(vc, animated: true)
    }
}
