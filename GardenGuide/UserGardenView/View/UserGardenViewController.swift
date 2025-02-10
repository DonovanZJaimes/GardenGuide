//
//  UserGardenViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/05/24.
//

import UIKit

class UserGardenViewController: UIViewController{
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    
    //MARK: general variables
    let searchController = UISearchController()
    lazy var controller =   UserGardenController(delegate: self)
    var gardenPlantsCell: [[GardenPlantCell]]!
    var dataSource: UICollectionViewDiffableDataSource<Section, ItemPlant>!
    var sections = [Section]()
    var isEditingMode: Bool = false
    var gardenPlants: [GardenPlant]! {
        didSet {
            configureImageView()
        }
    }
    var favouritePlants: [FavouritePlant]! {
        didSet {
            configureImageView()
        }
    }
    
    //MARK: Enums
    //Sections on CollectionView
    enum Section: Hashable {
        case favouritePlants
        case gardenPlants(String)
    }
    
    //suplementary views of the different sections
    enum SupplementaryViewKind {
        static let header = "header"
        static let subHeader = "subHeader"
        static let bottomLine = "bottomLine"
        //static let bottomHeader = "bottomLine"
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationItems()
        controller.getFavouritePlants()
        controller.getGardenPlants()
        settupCollectionView()
        configureDataSource()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFavouritePlants), name: Notifications.sendPlantNotification, object: nil)
        self.imageView.isHidden = true
        self.imageViewHeight.constant = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource.apply(plantSnapshot, animatingDifferences: true) {
            self.dataSource.apply(self.plantSnapshot, animatingDifferences: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureTabBarControllerItem()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.favouritePlants = self.favouritePlants
            appDelegate.gardenPlants = self.gardenPlants
        }
    }

    
    
    //MARK: General methods
    
    // method that updates the colour of the title and the items in the tab bar
    func configureNavigationItems(){
        //Configure the title
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "CustomLightGreen")!]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "CustomLightGreen")!]
        navigationItem.standardAppearance = appearance
        navigationItem.title = "GARDEN"
       
        //Setup right button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(editGeneralConfiguration))
        navigationItem.rightBarButtonItem?.tintColor = .customOpaqueGreen
    }
    
    func settupCollectionView() {
        //delegate
        collectionView.delegate = self
        //CollectionView layout
        collectionView.collectionViewLayout = createLayout()
        //register cells
        collectionView.register(UINib(nibName: "\(GardenPlantCollectionViewCell.self)", bundle: .main), forCellWithReuseIdentifier: "\(GardenPlantCollectionViewCell.self)")
        collectionView.register(UINib(nibName: "\(FavouritePlantCollectionViewCell.self)", bundle: .main), forCellWithReuseIdentifier: "\(FavouritePlantCollectionViewCell.self)")
        //register supplementary Views
        collectionView.register(SubHeaderCollectionReusableView.self, forSupplementaryViewOfKind: SupplementaryViewKind.subHeader, withReuseIdentifier: SubHeaderCollectionReusableView.reuseIdentifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: SupplementaryViewKind.header, withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier)
        collectionView.register(LineCollectionReusableView.self, forSupplementaryViewOfKind: SupplementaryViewKind.bottomLine, withReuseIdentifier: LineCollectionReusableView.reuseIdentifier)
    }
   
    
    //configure the CollectionView DataSource
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section,ItemPlant>(collectionView: collectionView, cellProvider: {  (collectionView, indexPath, item) -> UICollectionViewCell? in
            let section = self.sections[indexPath.section]
            //set the view depending on whether it will be for favouritePlant or GardePlant
            switch section {
            case .favouritePlants:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(FavouritePlantCollectionViewCell.self)", for: indexPath) as! FavouritePlantCollectionViewCell
                //get data for the cell
                let cornerRadius = (collectionView.bounds.height / 7 ) / 4
                let favouritePlant = FavouritePlant(name: item.favouritePlant?.name ?? "plant", image: item.favouritePlant?.image ?? Constants.imagePlant, min: item.favouritePlant?.min ?? 1, max: item.favouritePlant?.max ?? 1)
                //update cell
                cell.updateCell(name: item.favouritePlant?.name ?? "plant", image: item.favouritePlant?.image ?? Constants.imagePlant, cornerRadius: cornerRadius, favouritePlant: favouritePlant)
                cell.delegate = self
                return cell
            case .gardenPlants(_):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(GardenPlantCollectionViewCell.self)", for: indexPath) as! GardenPlantCollectionViewCell
                cell.updateCell(plant: item.gardenPlant!, isInEliminationMode: self.isEditingMode)
                cell.delegate = self
                return cell
            }
        })
        
        //set the suplementary views according to type
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath -> UICollectionReusableView? in
            switch kind {
            case SupplementaryViewKind.header:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! HeaderCollectionReusableView
                let section = self.sections[indexPath.section]
                switch section {
                case .favouritePlants:
                    let header = "Favourite Plants"
                    view.setTitle(header)
                    break
                case .gardenPlants(_):
                    let date = self.gardenPlantsCell[indexPath.section - 1].first?.nextIrrigation
                    let header = self.setTitle(date: date!)
                    view.setTitle(header, fontSize: 13, color: .lightGray)
                    break
                }
                return view
            case SupplementaryViewKind.subHeader:
                let subHeader: String = "Garden Plants"
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SubHeaderCollectionReusableView.reuseIdentifier, for: indexPath) as! SubHeaderCollectionReusableView
                view.setTitle(subHeader)
                return view
            case SupplementaryViewKind.bottomLine:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LineCollectionReusableView.reuseIdentifier, for: indexPath) as! LineCollectionReusableView
                return view
            default:
                return nil
            }
        }
        
        dataSource.apply(plantSnapshot)
    }
    
    // create CollectionView Layout
    func createLayout() -> UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            
            //create the configuration of supplementary views
            let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(33))
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: SupplementaryViewKind.header, alignment: .topLeading)
            
            let subHeaderItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(23))
            let subHeaderItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: subHeaderItemSize, elementKind: SupplementaryViewKind.subHeader, alignment: .bottomLeading)
            
            let lineItemHeight = 1 / layoutEnviroment.traitCollection.displayScale
            let lineItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.94), heightDimension: .absolute(lineItemHeight))
            let lineItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: lineItemSize, elementKind: SupplementaryViewKind.bottomLine, alignment: .bottom)
            
            let contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            headerItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 4, bottom: 4, trailing: 4)
            subHeaderItem.contentInsets = contentInsets
            lineItem.contentInsets = contentInsets
            
            //create the layout configuration of the collectionVIewCell
            let section = self.sections[sectionIndex]
            switch section {
            case .favouritePlants:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/5), heightDimension: .fractionalHeight(1/7))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [headerItem, lineItem, subHeaderItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 10, trailing: 0)
                section.orthogonalScrollingBehavior = .groupPaging
                return section
                
            case .gardenPlants(_):
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(105))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                //group.supplementaryItems =  [subHeaderItem]
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [headerItem, lineItem]
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 3, trailing: 0)
                return section
            }
        }
        return layout
    }
    
    
    var plantSnapshot: NSDiffableDataSourceSnapshot<Section, ItemPlant> {
        var plantSnapshot = NSDiffableDataSourceSnapshot <Section, ItemPlant>()
        //to favourirePlant section
        let favouritePlant = Section.favouritePlants
        plantSnapshot.appendSections([favouritePlant])
        plantSnapshot.appendItems(ItemPlant.favouritePlants, toSection: favouritePlant)
        
        //to gardenPlant section
        if let gardenPlantsCells  = gardenPlantsCell, gardenPlantsCells.count >= 1 {
            for index in 0 ..< gardenPlantsCell.count {
                let title: String = gardenPlantsCell[index].first?.nextIrrigation.formatted(date: .numeric, time: .omitted) ?? "title: \(index)"
                let gardenPlant = Section.gardenPlants(title)
                plantSnapshot.appendSections([gardenPlant])
                plantSnapshot.appendItems(ItemPlant.gardenPlants[index], toSection: gardenPlant)
            }
        }
        
        sections = plantSnapshot.sectionIdentifiers
        return plantSnapshot
    }
    
    //determine the title on the basis of the date received and the actual date
    func setTitle(date: Date) -> String {
        let today = Calendar.current.startOfDay(for: .now)
        let numericDate = date.formatted(date: .abbreviated, time: .omitted)
        let timeSeconds = today.timeIntervalSince(date)
        let days: Int  = abs(Int((((timeSeconds / 60) / 60 ) / 24 )))
        guard today <= date else {
            let dayOrDays = days == 1 ? "day" : "days"
            let title = "   \(days) " + dayOrDays + " late " + numericDate
            return title
        }
        if days <= 1{
            return "   Today"
        } else {
            return "   " + numericDate
        }
    }
    
    
    //configure Tab Bar Controller
    func configureTabBarControllerItem(){
        guard let _ = tabBarController?.tabBar.items?[1] else {return}
        Notifications.shared.newPlants.removeAll()
        tabBarController?.tabBar.items?[1].badgeValue = nil
        tabBarController?.tabBar.tintColor = .customGreen
    }
    
    func configureImageView() {
        DispatchQueue.main.async { [self] in
            if let _ = gardenPlants, let _ = favouritePlants {
                if gardenPlants.count == 0 && favouritePlants.count == 0 {
                    self.imageView.isHidden = false
                    self.imageViewHeight.constant = 210
                    imageLabel.text = "Search for plants in the search section"
                }
                
                if gardenPlants.count == 0 && favouritePlants.count != 0 {
                    self.imageView.isHidden = false
                    self.imageViewHeight.constant = 210
                    imageLabel.text = "Add plants from Favorite Plants "
                }
                
                if gardenPlants.count != 0 && favouritePlants.count != 0 {
                    self.imageView.isHidden = true
                    self.imageViewHeight.constant = 0
                }
            }
           
        }
    }
    
    //update GardenPlantCellItem with new GardenPlants
    func updateGardenPlantCellItem(gardenPlants: [GardenPlant]) {
        gardenPlantsCell = controller.getGardenPlantsCell(gardenPlants: gardenPlants)
        var itemPlants = [[ItemPlant]]()
        gardenPlantsCell.forEach { gardenPlantsCell in
            itemPlants.append(gardenPlantsCell.map {ItemPlant.gardenPlant($0)})
        }
        ItemPlant.gardenPlants = itemPlants
        
    }
    
    
    //MARK: ViewController Actions
    
    //activate method in case of another view added a new favouritePlant
    @objc func updateFavouritePlants(){
        //get the favouritePlants without the gardenPlants
        var gardenPlantNames = [String]()
        gardenPlants.forEach { gardenPlant in
            gardenPlantNames.append(gardenPlant.plantInformation.name)
        }
        let newFavouritePlants = controller.getNewFavouritePlants(without: gardenPlantNames)
        
        //update the new FavouritePlants
        favouritePlants = newFavouritePlants
        ItemPlant.favouritePlants = favouritePlants.map {ItemPlant.favouritePlant($0)}
        Task {
            await MainActor.run {
                dataSource.apply(plantSnapshot, animatingDifferences: true)
            }
        }
    }
    
    //present SettingsViewController with specific information
    @objc func editGeneralConfiguration(){
        let vc = SettingsViewController()
        vc.delegate = self
        vc.isEditingMode = isEditingMode
        present(vc, animated: true)
    }
    
    
}

//MARK: Extension of UserGardenView Controller
extension UserGardenViewController: UserGardenControllerDelegate {
    func getNewGardenPlantFromFavouritePlant() {
       print("getNewGardenPlantFromFavouritePlant")
    }
    
    //get the GardenPlants to CollectionView
    func getInformationAboutGardenPlants() {
        //get and update data
        self .gardenPlants = controller.gardenPlants
        updateGardenPlantCellItem(gardenPlants: gardenPlants)
        controller.savePlantsInCoreData(gardenPlants)
        //update CollectionView
        Task {
            await MainActor.run {
                dataSource.apply(plantSnapshot, animatingDifferences: true)
            }
        }
    }
    
    //get the GFavouritePlants to CollectionView
    func getInformationAboutFavouritePlants() {
        //get and update data
        self.favouritePlants = controller.favouritePlants
        ItemPlant.favouritePlants = favouritePlants.map {ItemPlant.favouritePlant($0)}
        //update CollectionView
        Task {
            await MainActor.run {
                dataSource.apply(plantSnapshot, animatingDifferences: true)
            }
        }
    }
}

//MARK: Extension of CollectionViewDelegate
extension UserGardenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Determine whether the selected view was in FavouritePlant or GardenPlant.
        switch indexPath.section {
        case 0:
            //get data plant and present it in PlantDetailsViewController
            let favouritePlantName = favouritePlants[indexPath.row].name
            Task {
                let gardenPlant = try await controller.getGardenPlantFromFavouritePlant(name: favouritePlantName, watered: Constants.irrigationInformation)
                controller.savePlantsInCoreData([gardenPlant])
                presentPlantDetailsViewController(withWateredView: false, gardenPlant: gardenPlant)
            }
        default:
            //get data plant and present it in PlantDetailsViewController
            let gardenPlantCell = gardenPlantsCell[indexPath.section - 1][indexPath.row]
            var gardenPlant: GardenPlant!
            for index in 0 ..< gardenPlants.count {
                if gardenPlantCell.name == gardenPlants[index].plantInformation.name {
                    gardenPlant = gardenPlants[index]
                    break
                }
            }
            presentPlantDetailsViewController(withWateredView: true, gardenPlant: gardenPlant, watered: gardenPlant.watered)
        }
        
    }
    
    private func presentPlantDetailsViewController(withWateredView: Bool, gardenPlant: GardenPlant, watered: IrrigationInformation? = nil) {
        let suggestedPlant = controller.convertGardenPlantModelToSuggestedPlant(gardenPlant)
        let vc = PlantDetailsViewController()
        vc.suggestedPlant = suggestedPlant
        vc.hasWatered = withWateredView
        vc.watered = watered
        present(vc, animated: true)
    }
}

//MARK: Extension of FavouritePlant Cell
extension UserGardenViewController: FavouritePlantCollectionViewCellDelegate {
    //present new view to add watering
    func favouritePlantConfiguration(favouritePlant: FavouritePlant) {
        let vc = AddIrrigationViewController()
        vc.favouritPlant = favouritePlant
        vc.delegate = self
        present(vc, animated: true)
    }
}

//MARK: Extension of GardenPlant Cell
extension UserGardenViewController: GardenPlantCollectionViewCellDelegate {
    //delete the gardenPlant selected
    func deleteGardenPlant(name: String, sender: UIButton) {
        sendMessageToUserToDeleteAPlant(sender, name: name) { [self] isEliminated in
            guard isEliminated else {return}
            //get index
            var indexPlant = 0
            for index in 0 ..< gardenPlants.count {
                if name == gardenPlants[index].plantInformation.name {
                    indexPlant = index
                    break
                }
            }
            //Delete Plant
            let gardenPlant = gardenPlants.remove(at: indexPlant)
            CoreDataUtils.shared.deletePlant(withName: name)
            deleteGardenPlantToFirestoreCloud(gardenPlant)
            
            
            //Update Data
            updateGardenPlantCellItem(gardenPlants: gardenPlants)
            Task {
                await MainActor.run {
                    dataSource.apply(plantSnapshot, animatingDifferences: true)
                }
            }
        }
    }
    
    //alert controlller to select whether or not the plant can be removed
    private func sendMessageToUserToDeleteAPlant(_ sender: UIButton, name: String, completion: @escaping (Bool) -> Void) {
        //create alert Controller
        let title = "Do you want to remove the plant: " + name + " form your garden?"
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        //create alert actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completion(false)
        })
        alertController.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: "Yes, delete it", style: .default) { action in
            completion(true)
        }
        alertController.addAction(deleteAction)
        alertController.editButtonItem.tintColor = .customGreen
        //present
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }
    
    //delete GardenPlant To Firestore Cloud
    private func deleteGardenPlantToFirestoreCloud(_ gardenPlant: GardenPlant) {
        let plantForFirestore = FirestoreUtilts.shared.plantInformationModelToPlantForFirestoreModel(gardenPlant.plantInformation, watered: gardenPlant.watered)
        Task {
            await makeMethodsForFirestoreCloud {
                await FirestoreDeleteData.shared.deleteGardenPlantToCloud(plantForFirestore)
            }
        }
    }
    
    //present new view to update watering in GardenPlant
    func editPlantWatering(name: String) {
        let (favouritePlant, irrigationInformation) = getModelsToEditPlantWatering(name: name)
        let vc = AddIrrigationViewController()
        vc.favouritPlant = favouritePlant
        vc.irrigationInformation = irrigationInformation
        vc.delegate = self
        present(vc, animated: true)
    }
    
    private func getModelsToEditPlantWatering(name: String) -> (FavouritePlant, IrrigationInformation) {
        //get plant selected
        var gardenPlant: GardenPlant!
        for index in 0 ..< gardenPlants.count {
            if name == gardenPlants[index].plantInformation.name {
                gardenPlant = gardenPlants[index]
                break
            }
        }
        //get new data
        let favouritePlant = FavouritePlant(name: name, image: gardenPlant.plantInformation.details.image?.url ?? Constants.imagePlant, min: gardenPlant.plantInformation.details.watering?.min ?? 1, max: gardenPlant.plantInformation.details.watering?.max ?? 1)
        let irrigationInformation = gardenPlant.watered
        return (favouritePlant, irrigationInformation)
    }
    
    //update the collectionView with new data
    func updateColectionView() {
        //update data
        updateGardenPlantCellItem(gardenPlants: gardenPlants)
        //update collectionView
        dataSource.apply(plantSnapshot, animatingDifferences: true){
            self.dataSource.apply(self.plantSnapshot, animatingDifferences: false)
        }
    }
    
    //Method for watering the gardenPlant
    func gardenPlantConfiguration(name: String, sender: UIButton, completion: @escaping (Bool) -> Void) {
        let today = Calendar.current.startOfDay(for: .now)
        gardenPlants.forEach { gardenPlant in
            guard gardenPlant.plantInformation.name == name else { return }
            //update watering
            if today >= gardenPlant.watered.nextIrrigation {
                updatePlantWatering(plant: gardenPlant)
                completion(true)
            } else {
                // verify if the plant watering will update
                let daysSeconds = gardenPlant.watered.nextIrrigation.timeIntervalSinceNow
                let days = (( daysSeconds / 24 ) / 60 ) / 60
                sendMessageToUser(sender, text: name, days: Int(days), plant: gardenPlant) {  result in
                    completion(result)
                }
            }
        }
    }
    
    //create and present the AlertController
    private func sendMessageToUser(_ sender: UIButton, text: String, days: Int, plant: GardenPlant, completion: @escaping (Bool) -> Void) {
        //create alert Controller
        let title = "Are you sure you want to water the " + text + " plant? "
        let subTitle = "There are still \(days) days to water this plant."
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        //create alert actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completion(false)
        })
        alertController.addAction(cancelAction)
        let wateredAction = UIAlertAction(title: "Yes, watering", style: .default) { [weak self] action in
            self?.updatePlantWatering(plant: plant)
            completion(true)
        }
        alertController.addAction(wateredAction)
        alertController.editButtonItem.tintColor = .customGreen
        //present
        alertController.popoverPresentationController?.sourceView = sender
        present(alertController, animated: true)
    }
    
    //update gardenPlant drop
    private func updatePlantWatering(plant: GardenPlant) {
        //create a new Irrigarion Information
        let numberOfDays = plant.watered.numberOfDays
        let waterAmount = plant.watered.waterAmount
        let percentage = plant.watered.percentage
        let wasItWatered = true
        let nextIrrigation = Calendar.current.date(byAdding: .day, value: Int(plant.watered.numberOfDays), to: .now)
        let newIrrigation = IrrigationInformation(numberOfDays: numberOfDays, waterAmount: waterAmount, percentage: percentage, wasItWatered: wasItWatered, nextIrrigation: nextIrrigation!)
        // update watering on Core Data
        CoreDataUtils.shared.updatePlantWatering(name: plant.plantInformation.name, watered: newIrrigation)
        // update watering on array
        for index in 0 ..< gardenPlants.count {
            if plant.plantInformation.name == gardenPlants[index].plantInformation.name {
                gardenPlants[index].watered = newIrrigation
            }
        }
    }
}

//MARK: Extension  to send the result of AddIrrigation View
extension UserGardenViewController: AddIrrigationViewControllerDelegate {
    //update the new irrigation gardenPlant
    func updatePlantWatering(name: String, irrigationInformation: IrrigationInformation) {
        //get gardenPlant data
        var gardenPlant: GardenPlant!
        var indexPlant = 0
        for index in 0 ..< gardenPlants.count {
            if name == gardenPlants[index].plantInformation.name {
                gardenPlant = gardenPlants[index]
                indexPlant = index
                break
            }
        }
        //Update data
        gardenPlant.watered = irrigationInformation
        gardenPlants[indexPlant].watered = irrigationInformation
        updateGardenPlantCellItem(gardenPlants: gardenPlants)
        Task {
            await MainActor.run {
                dataSource.apply(plantSnapshot, animatingDifferences: true)
            }
        }
        //Save Data
        controller.savePlantsInCoreData([gardenPlant])
        Task {
            await makeMethodsForFirestoreCloud {
                await FirestoreEditData.shared.editIrrigationInformationOfGardenPlant(name: name, watered: irrigationInformation)
            }
        }
    }
    
    //get new irriagtion favouritePlant
    func addFavouritePlantToGardenPlant(_ favouritePlant: FavouritePlant, irrigationInformation: IrrigationInformation) {
        Task {
            do {
                //Get the new GardenPlant
                let newGardenPlant = try await controller.getGardenPlantFromFavouritePlant(name: favouritePlant.name, watered: irrigationInformation)
                //Update data
                gardenPlants.append(newGardenPlant)
                updateGardenPlantCellItem(gardenPlants: gardenPlants)
                updateItemFromFavouritePlantSection(name: favouritePlant.name)
                // Apply snapshot on the main thread explicitly
                await MainActor.run {
                    dataSource.apply(plantSnapshot, animatingDifferences: true)
                }
                
                //save Data
                controller.savePlantsInCoreData([newGardenPlant])
                Task {
                    await makeMethodsForFirestoreCloud {
                        let plantForFirestore = FirestoreUtilts.shared.plantInformationModelToPlantForFirestoreModel(newGardenPlant.plantInformation, watered: newGardenPlant.watered)
                        await FirestoreAddData.shared.addGardenPlantToCloud(plantForFirestore)
                        await FirestoreDeleteData.shared.deletePlantOfFavouritesToCloud(plantForFirestore.name)
                    }
                }
            }catch {
                print("Error adding new GardenPlant: \(error)")
            }
        }
    }
    
    //delete the favouritePlant in collectionView
    private func updateItemFromFavouritePlantSection(name: String){
        var indexPlant = 0
        for index in 0 ..< ItemPlant.favouritePlants.count {
            if name == ItemPlant.favouritePlants[index].favouritePlant?.name {
                indexPlant = index
                break
            }
        }
        ItemPlant.favouritePlants.remove(at: indexPlant)
    }
}

//MARK: Extension of SettingsView
extension UserGardenViewController: SettingsViewControllerDelegate {
    //get info of SettingsView
    func deletingCellsFromThePlantGarden(_ isEditingMode: Bool) {
        self.isEditingMode = isEditingMode
        dataSource.applySnapshotUsingReloadData(plantSnapshot)
    }
}
