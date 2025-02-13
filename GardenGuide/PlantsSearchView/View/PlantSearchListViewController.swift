//
//  PlantSearchListViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 28/05/24.
//

import UIKit
//MARK: Delegate form the PlantSearchListViewController
protocol PlantSearchListViewControllerDelegate: AnyObject {
    //Information for the GardenGuideViewController
    func plantSearchListViewController(_ controller: PlantSearchListViewController, accessToken: String, name: String)
}

class PlantSearchListViewController: UIViewController {
    
    //MARK: general variables
    var tableView = UITableView()
    lazy var controller = PlantSearchListController(delegate: self)
    var plantsList = [SuggestedPlantName]()
    weak var delegate: PlantSearchListViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    //MARK: gerenal Methods
    func configureTableView() {
        view.addSubview(tableView)
        //DataSource and Delegate
        tableView.delegate = self
        tableView.dataSource = self
        //Register cell
        tableView.register(UINib(nibName: "\(SearchPlantForTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(SearchPlantForTableViewCell.self)")
        //Frame
        constraintsForTableView()
    }
    
    
    func constraintsForTableView() {
        //Add the constraints of the table view and the viewController
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
    }
    
    //Calls the Controller method
    func searchListOfPlants(word: String){
        controller.lookForPlants(word: word)
    }
    
}

//MARK: PlantSearchListController delegate methods
extension PlantSearchListViewController: PlantSearchListControllerDelegate {
    func getListOfPlantNamesByText() {
        //Update new table view values
        plantsList = controller.plantsResults
        tableView.reloadData()
    }
    
    
}

//MARK: Extension for table view Delegate and DataSource
extension PlantSearchListViewController: UITableViewDelegate, UITableViewDataSource {
    //Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plantsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //get data
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SearchPlantForTableViewCell.self)", for: indexPath) as! SearchPlantForTableViewCell
        let plant = plantsList[indexPath.row]
        //config cell with data
        cell.configureCell(plant: plant)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let plant = plantsList[indexPath.row]
        let accessToken = plant.accessToken
        let name = plant.plantName
        //Send cell information to GardenGuideViewController
        delegate?.plantSearchListViewController(self, accessToken: accessToken, name: name)
        dismiss(animated: true)
    }
    
    
    
}
