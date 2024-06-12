//
//  ButtonDetailsViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 06/06/24.
//

import UIKit

class ButtonDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var wateredMinLabel: UILabel!
    @IBOutlet weak var wateredMaxLabel: UILabel!
    @IBOutlet weak var wateredMinProgressView: UIProgressView!
    @IBOutlet weak var wateredMaxProgressView: UIProgressView!
    @IBOutlet weak var wateredDescriptionLabel: UILabel!
    @IBOutlet weak var heighViewOfWatered: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var wateredView: UIView!
    @IBOutlet weak var titleListLabel: UILabel!
    @IBOutlet weak var wateredStackView: UIStackView!
    
    //MARK: general variables
    var isTheViewForTheWateringButton: Bool = false
    var listOfInformation: [String]?
    var minHumidity: Int?
    var maxHumidity: Int?
    var plantName: String?
    var titleList: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUISheetPresentationController()
        determineTheInformationToPresent(isTheWateringViewHidden: isTheViewForTheWateringButton)
        titleListLabel.text = titleList
    }
    
    //MARK: General methods
    
    //Determine which view will be presented
    func determineTheInformationToPresent(isTheWateringViewHidden: Bool){
        //set the viewController in case the view is for watering or not
        guard isTheWateringViewHidden else {
            //If you do not use the irrigation view it will be hidden and the tableView will be shown
            heighViewOfWatered.constant = 0
            wateredView.isHidden = true
            configTableView()
            return
        }
        // update the irrigation view if selected and hide TableView
        tableView.isHidden = true
        configWateredView()
    }
    
    
    func configWateredView(){
        guard let minHumidity = minHumidity, let maxHumidity = maxHumidity, let plantName = plantName, minHumidity != 0 else {
            //in case you select irrigation view but do not have information
            wateredDescriptionLabel.text = "No information was found on watering the plant " + (plantName ?? "")
            wateredStackView.isHidden = true
            return
            
        }
        //in case you have irrigation information
        let minHumidityString = determineHumidity(minHumidity)
        let maxHumidityString = determineHumidity(maxHumidity)
        
        //Config Labels
        wateredMinLabel.text = "Min: " + String(minHumidity)
        wateredMaxLabel.text = "Max: " + String(maxHumidity)
        wateredDescriptionLabel.text = plantName + " prefers a " + minHumidityString + " to " + maxHumidityString + " environment"
        
        //config Progress View
        wateredMaxProgressView.progress = determineProgressView(maxHumidity)
        wateredMinProgressView.progress = determineProgressView(minHumidity)
        
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


    func configTableView() {
        //Data Source and Delegate
        tableView.delegate = self
        tableView.dataSource = self
        //Register Cell
        tableView.register(UINib(nibName: "\(ButtonInformationListTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(ButtonInformationListTableViewCell.self)")
    }
    
    
    func configUISheetPresentationController() {
        //Determine the form the type of presentation that the viewController will have
        guard let presentationController = presentationController as? UISheetPresentationController else {return}
        presentationController.detents = [.medium()]
        presentationController.selectedDetentIdentifier = .large
        presentationController.prefersGrabberVisible = true
        presentationController.preferredCornerRadius = 30
    }

}

//MARK: Extension for UITableViewDelegate and  UITableViewDataSource
extension ButtonDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    //Methots for UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listOfInformation!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ButtonInformationListTableViewCell.self)", for: indexPath) as! ButtonInformationListTableViewCell
        let info = listOfInformation![indexPath.row]
        cell.configCell(info)
        return cell
    }
    
    //Methots for UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
}
