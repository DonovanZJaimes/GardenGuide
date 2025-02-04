//
//  AddIrrigationViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 17/12/24.
//

import UIKit
import Kingfisher

protocol AddIrrigationViewControllerDelegate: AnyObject {
    func addFavouritePlantToGardenPlant(_ favouritePlant: FavouritePlant, irrigationInformation: IrrigationInformation)
    func updatePlantWatering(name: String,  irrigationInformation: IrrigationInformation )
}

class AddIrrigationViewController: UIViewController {
    
    @IBOutlet var minLabel: UILabel!
    @IBOutlet var maxLabel: UILabel!
    @IBOutlet var minProgressView: UIProgressView!
    @IBOutlet var maxProgressView: UIProgressView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageImageView: UIImageView!
    @IBOutlet var descriptionWateringLabel: UILabel!
    @IBOutlet var nextWateringTextField: UITextField!
    @IBOutlet var amountOfWaterTextField: UITextField!
    @IBOutlet var finalDescriptionLabel: UILabel!
    @IBOutlet var AddingPlantButton: UIButton!
    
    var amountOfWaterPickerView = UIPickerView()
    var irrigationCalendarView = UICalendarView()
    var favouritPlant: FavouritePlant!
    let amountsOfWater = ["50","100","150","200","250","300","400","500","600","700","800","900","1000","2000","3000","4000","5000"]
    var nextIrrigation: Date?
    var irrigationInformation: IrrigationInformation? = nil
    weak var delegate: AddIrrigationViewControllerDelegate?
    
    lazy var irrigationCalendar: UICalendarView = {
        let selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
        let calendar = UICalendarView()
        calendar.locale = .current
        calendar.selectionBehavior = selectionBehavior
        calendar.translatesAutoresizingMaskIntoConstraints = false
        // date Interval
        let oneMonth = ((24 * 60) * 60) * 30
        let dateInterval = DateInterval(start: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, duration: TimeInterval(oneMonth))
        calendar.availableDateRange = dateInterval
        return calendar
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUISheetPresentationController()
        configGeneralView()
        setUpPickerView()
        setUpCalendarView()
        updateButtonGarden()
    }
    
    func configUISheetPresentationController() {
        //Determine the form the type of presentation that the viewController will have
        guard let presentationController = presentationController as? UISheetPresentationController else {return}
        presentationController.detents = [.medium()]
        presentationController.selectedDetentIdentifier = .large
        presentationController.prefersGrabberVisible = true
        presentationController.preferredCornerRadius = 30
    }
    
    func configGeneralView() {
        //labels
        nameLabel.text = favouritPlant.name
        maxLabel.text = "Max: " + String(favouritPlant.max)
        minLabel.text = "Min: " + String(favouritPlant.min)
        let minHumidityString = determineHumidity(favouritPlant.min)
        let maxHumidityString = determineHumidity(favouritPlant.max)
        descriptionWateringLabel.text = favouritPlant.name + " prefers a " + minHumidityString + " to " + maxHumidityString + " environment"
        finalDescriptionLabel.isHidden = true
        
        //progressViews
        minProgressView.progress = determineProgressView(favouritPlant.min)
        maxProgressView.progress = determineProgressView(favouritPlant.max)
        
        //Image
        guard let urlImage = URL(string: favouritPlant.image) else {
            imageImageView.image = UIImage(systemName: "leaf.fill")
            imageImageView.tintColor = .customGreen
            imageImageView.contentMode = .scaleAspectFit
            return
        }
        imageImageView.kf.setImage(with: urlImage)
        imageImageView.layer.cornerRadius = imageImageView.frame.height / 5
        
        //button
        AddingPlantButton.isEnabled = false
        AddingPlantButton.layer.cornerRadius = AddingPlantButton.frame.height / 3
        
        if let irrigationInformation = irrigationInformation {
            nextWateringTextField.text = irrigationInformation.nextIrrigation.formatted(date: .abbreviated, time: .omitted)
            amountOfWaterTextField.text = String(irrigationInformation.waterAmount) + " ml"
            nextIrrigation = irrigationInformation.nextIrrigation
            finalDescriptionLabel.text = setUpFinalDescription()
            
        }
    
    }
    
    func setUpPickerView() {
        amountOfWaterPickerView.delegate = self
        amountOfWaterPickerView.dataSource = self
        amountOfWaterTextField.inputView = amountOfWaterPickerView
    }
    
    func setUpCalendarView() {
        nextWateringTextField.inputView = irrigationCalendar
    }
    
    func determineHumidity(_ Humidity: Int) -> String {
        //determine the type of humidity of the plant by means of a number
        switch Humidity {
        case 1:
            return "dry"
        case 2:
            return "medium"
        default: // 3
            return "wet"
        }
    }
    
    func determineProgressView(_ Humidity: Int) -> Float {
        //determine the progressView by means of humidity
        switch Humidity {
        case 1:
            return 0.0
        case 2:
            return 0.5
        default: // 3
            return 1.0
        }
    }
    
    func updateButtonGarden() {
        let title = self.irrigationInformation == nil ? "Adding a plant to my garden" : "Update Plant Watering"
        AddingPlantButton.setTitle(title, for: .normal)
        
        guard !nextWateringTextField.text!.isEmpty  && !amountOfWaterTextField.text!.isEmpty else {
            AddingPlantButton.isEnabled = false
            finalDescriptionLabel.isHidden = true
            return
        }
        AddingPlantButton.isEnabled = true
        finalDescriptionLabel.text = setUpFinalDescription()
        finalDescriptionLabel.isHidden = false
        
    }
    
    func setUpFinalDescription() -> String {
        let secondsInterval = Date().timeIntervalSince(self.nextIrrigation!)
        let daysInterval = abs(Int(secondsInterval / (60 * 60 * 24) ) ) + 1
        let days = daysInterval == 1 ? "day" : "days"
        let amount = amountOfWaterTextField.text
        let finalDescription = "Every \(daysInterval) " + days + " you should water your plant with an amount of " + amount!
        return finalDescription
    }

    @IBAction func AddingPlantToMyGarden(_ sender: UIButton) {
        let daysInterval = abs(Int(Date().timeIntervalSince(self.nextIrrigation!) / (60 * 60 * 24) ) ) + 1
        let waterAmount = Int16((amountOfWaterTextField.text?.replacingOccurrences(of: " ml", with: ""))! ) ?? 0
        let irrigationInformation = IrrigationInformation(numberOfDays: Int16(daysInterval), waterAmount: waterAmount, percentage: 1, wasItWatered: false, nextIrrigation: self.nextIrrigation!)
        if self.irrigationInformation == nil {
            delegate?.addFavouritePlantToGardenPlant(favouritPlant, irrigationInformation: irrigationInformation)
        } else {
            delegate?.updatePlantWatering(name: favouritPlant.name, irrigationInformation: irrigationInformation)
        }
        dismiss(animated: true)
    }
}

extension AddIrrigationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return amountsOfWater.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0 :
            return  amountsOfWater[row]
        default:
            return "ml"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard component == 0 else {return}
        amountOfWaterTextField.text = amountsOfWater[row] + " ml"
        amountOfWaterTextField.resignFirstResponder()
        updateButtonGarden()
    }
}

extension AddIrrigationViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        nextWateringTextField.text = dateComponents?.date?.formatted(date: .abbreviated, time: .omitted)
        nextWateringTextField.resignFirstResponder()
        nextIrrigation = dateComponents?.date
        updateButtonGarden()
    }
}
