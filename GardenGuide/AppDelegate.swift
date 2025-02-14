//
//  AppDelegate.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/04/24.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var favouritePlants = [FavouritePlant]()
    var gardenPlants = [GardenPlant]()



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Firebase
        FirebaseApp.configure()
        //Google Auth
        /*if let clientID = FirebaseApp.app()?.options.clientID {
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
        }*/

        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveDataOnFirestore()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveDataOnFirestore()
    }
    
    private func saveDataOnFirestore() {
        //get plant in CoreData
        let dataManager = CoreDataPlant()
        let plantsEntity = dataManager.fetchPlants()
        for index in 0 ..< plantsEntity.count {
            guard plantsEntity[index].isAdded  else { continue }
            //get a specific plant
            let plantEntity = plantsEntity[index]
            let watered = dataManager.fetchWatered(plant: plantEntity)
            
            guard watered?.numberOfDays != -1 || watered?.waterAmount != 0 else {
                //Save the favouritePlant on Firestore Cloud
                let (isAdded, favouritePlant) = isPlantInFavouritePlants(name: plantEntity.name!)
                switch isAdded {
                case true:
                    saveFavouritePlantOnFirestore(favouritePlant!)
                case false:
                    saveFavouritePlantOnFirestore(plantEntity, dataManager: dataManager)
                }
                continue
            }
            //Save the gardenPlant on Firestore Cloud
            let (isAdded, gardenPlant) = isPlantInGardenPlants(name: plantEntity.name!)
            switch isAdded {
            case true:
                saveGardenPlantOnFirestore(gardenPlant!)
            case false:
                saveGardenPlantOnFirestore(plantEntity, dataManager: dataManager)
            }
            continue
            
            
        }
    }
    
    //verify if the plat is in the FavouritPlant list
    private func isPlantInFavouritePlants(name: String) -> (Bool, FavouritePlant?) {
        var favouritePlant: FavouritePlant?
        var flag = false
        for index in 0 ..< favouritePlants.count {
            if favouritePlants[index].name == name {
                flag = true
                favouritePlant = favouritePlants[index]
                break
            }
        }
        return (flag, favouritePlant)
    }
    
    
    private func saveFavouritePlantOnFirestore(_ favouritePlant: FavouritePlant){
        Task{
            await makeMethodsForFirestoreCloud {
                await FirestoreAddData.shared.addPlantOfFavouritesToCloud(favouritePlant)
            }
        }
    }
    
    private func saveFavouritePlantOnFirestore(_ plant: PlantEntity, dataManager: CoreDataPlant) {
        //get data
        let detailsEntity = dataManager.fetchPlantDetails(plant: plant)
        let name = plant.name
        let max: Int = Int(detailsEntity?.wateringMax ?? 1)
        let min: Int = Int(detailsEntity?.wateringMin ?? 1)
        let image = detailsEntity?.descriptionImageUrl ?? Constants.imagePlant
        let favouritePlant = FavouritePlant(name: name!, image: image, min: min, max: max)
        //save data
        Task{
            await makeMethodsForFirestoreCloud {
                await FirestoreAddData.shared.addPlantOfFavouritesToCloud(favouritePlant)
            }
        }
    }
    
    //verify if the plat is in the GardenPlant list
    private func isPlantInGardenPlants(name: String) -> (Bool, GardenPlant?) {
        var gardenPlant: GardenPlant?
        var flag = false
        for index in 0 ..< gardenPlants.count {
            if gardenPlants[index].plantInformation.name == name {
                gardenPlant = gardenPlants[index]
                flag = true
                break
            }
        }
        return (flag, gardenPlant)
    }
    
    
    private func saveGardenPlantOnFirestore(_ gardenPlant: GardenPlant) {
        let plantForFirestore = FirestoreUtilts.shared.plantInformationModelToPlantForFirestoreModel(gardenPlant.plantInformation, watered: gardenPlant.watered)
        //save data
        Task{
            await makeMethodsForFirestoreCloud {
                await FirestoreAddData.shared.addGardenPlantToCloud(plantForFirestore)
            }
        }
    }
    
    private func saveGardenPlantOnFirestore(_ plant: PlantEntity, dataManager: CoreDataPlant){
        //get and convert data
        let planInformation = convertPlantEntityModelPlantInformation(plant, dataManager: dataManager)
        guard let watered = dataManager.fetchWatered(plant: plant) else {return}
        let irrigationInformation = IrrigationInformation(numberOfDays: watered.numberOfDays, waterAmount: watered.waterAmount, percentage: watered.percentage, wasItWatered: watered.wasItWatered, nextIrrigation: (watered.nextIrrigation)!)
        let plantForFirestore = FirestoreUtilts.shared.plantInformationModelToPlantForFirestoreModel(planInformation, watered: irrigationInformation)
        //save data
        Task{
            await makeMethodsForFirestoreCloud {
                await FirestoreAddData.shared.addGardenPlantToCloud(plantForFirestore)
            }
        }
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
