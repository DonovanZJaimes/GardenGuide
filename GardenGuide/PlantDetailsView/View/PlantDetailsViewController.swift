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
    //general
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
    
    //Irrigation view
    @IBOutlet weak var amountOfWaterLabel: UILabel!
    @IBOutlet weak var lastIrrigationLabel: UILabel!
    @IBOutlet weak var nextIrrigationLabel: UILabel!
    @IBOutlet weak var irrigationInformationLabel: UILabel!
    @IBOutlet weak var percentageOfWaterLabel: UILabel!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var wateredView: UIView!
    
    
    //MARK: general variables
    var plantInformation: PlantInformation!
    var name: String?
    var accessToken: String?
    var suggestedPlant: SuggestedPlant?
    var watered: IrrigationInformation?
    //var numberOfImages = 1
    var hasWatered: Bool = false
    //Core Data
    //let dataManager = CoreDataPlant()
    //Controller for de ViewController
    lazy var controller = PlantDetailsController(delegate: self)
    private var firestoreUtilts = FirestoreUtilts()
    
    
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
    
    //Configure ButtonIconList view
    func configHorizontalButtons(){
        //Get Information for ButtonIconList
        let options =  controller.getButtonDetailsList()
        buttonsIconListView.butonIconList = options
        buttonsIconListView.delegate = self
        //Build ButtonIconList
        buttonsIconListView.buildView()
    }
    
    
    //MARK: General settings for watering view
    
    //hide or show the watered view
    func configWateredView() {
        //hide or not
        switch hasWatered {
        case true:
            wateredView.isHidden = false
            plantWateringViewHeight.constant = 130
            configWateredViewLabels()
        case false:
            wateredView.isHidden = true
            topLineView.isHidden = true
            bottomLineView.isHidden = true
            plantWateringViewHeight.constant = 0
        }
    }
    
    // Config the watered view labels
    func configWateredViewLabels() {
        guard let watered = watered else {return}
        //config Labels
        amountOfWaterLabel.text = String(watered.waterAmount) + " ml"
        let (date, color) = setNextIrrigationLabel(date: watered.nextIrrigation)
        nextIrrigationLabel.text = date
        nextIrrigationLabel.textColor = color
        let lastIrrigation = Calendar.current.date(byAdding: .day, value: -Int(watered.numberOfDays), to: watered.nextIrrigation)
        lastIrrigationLabel.text = lastIrrigation?.formatted(date: .abbreviated, time: .omitted)
        irrigationInformationLabel.text = "The plant is watered every \(watered.numberOfDays) days with \(watered.waterAmount) ml of water."
        
        percentageOfWaterLabel.text = calculateWaterPercentage(lastIrrigation: lastIrrigation!)
    }
    
    //Get design information of a label
    func setNextIrrigationLabel(date: Date) -> (String, UIColor) {
        let today = Calendar.current.startOfDay(for: .now)
        let numericDate = date.formatted(date: .abbreviated, time: .omitted)
        let timeSeconds = today.timeIntervalSince(date)
        let days: Int  = abs(Int((((timeSeconds / 60) / 60 ) / 24 )))
        guard today <= date else {
            let dayOrDays = days == 1 ? "day" : "days"
            let title = "\(days) " + dayOrDays + " late, " + numericDate
            return (title, .red)
        }
        if days <= 1{
            return ("Today", .label)
        } else {
            return (numericDate, .label)
        }
    }
    
    //Obtain remaining water percentage
    func calculateWaterPercentage(lastIrrigation: Date) -> String {
        var percentage = 0
        if nextIrrigationLabel.text!.localizedStandardContains("late") || nextIrrigationLabel.text!.localizedStandardContains("Today") {
            return "\(percentage) %"
        }
        let seconds = lastIrrigation.timeIntervalSinceNow
        let days = abs( (( seconds / 24 ) / 60 ) / 60 )
        percentage = Int( (100.0 / Double(watered!.numberOfDays) ) * (Double(watered!.numberOfDays) - days))
        return "\(percentage) %"
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
        //Update heartButton
        heartButton.isSelected = CoreDataUtils.shared.plantIsInFavorites(plantInformation)
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
    
    
    //MARK: Alert Controller
    func sendMessageToUser(_ sender: UIButton, text: String) {
        let alertController = UIAlertController(title: "The plant is already saved", message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }
    


    //MARK: viewController actions
    
    @IBAction func heartButtonPressed(_ sender: UIButton) {
        //save or delete the plant from the favourites in CoreData
        CoreDataUtils.shared.addPlantToFavorites(name: plantInformation.name, selectedForFavorites: !sender.isSelected) { text in
            //print(text.rawValue)
            //Perform an action depending on the result
            let favouritePlant = FavouritePlant(name: plantInformation.name, image: plantInformation.details.image?.url ?? Constants.imagePlant, min: self.plantInformation.details.watering?.min ?? 1, max: plantInformation.details.watering?.max ?? 1)
            switch text {
            case .save:
                sender.isSelected = true
                controller.favouritePlantIsKept(true, withName: plantInformation.name, image: plantInformation.details.image?.url ?? Constants.imagePlant, plant: favouritePlant)
                break
            case .dontDelete:
                sendMessageToUser(sender, text: text.rawValue)
                heartButton.isSelected = true
                break
            case .alreadySaved:
                sendMessageToUser(sender, text: text.rawValue)
                break
            case .alreadyDelete:
                sendMessageToUser(sender, text: text.rawValue)
            case .delete:
                controller.favouritePlantIsKept(false, withName: plantInformation.name, image: plantInformation.details.image?.url ?? Constants.imagePlant, plant: favouritePlant)
                sender.isSelected = false
            }
        }
    }
    
    //display the view in safari to show the plant information
    @IBAction func readMoreButtonPressed(_ sender: UIButton) {
        //Open a safari page for more information about the plant
        guard let urlString = plantInformation.details.url, let url = URL(string: urlString)  else {
            sender.isEnabled = true
            return
        }
        let safariController = SFSafariViewController(url: url)
        present(safariController, animated: true)
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
        //Verify if plant is saved in CoreData
        CoreDataUtils.shared.saveNewPlant(plantInformation)
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
