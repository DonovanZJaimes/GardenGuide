//
//  UserGardenController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import Foundation
//MARK: Delegate for UserGardenController
protocol UserGardenControllerDelegate: AnyObject {
    func getInformationAboutGardenPlants()
    func getInformationAboutFavouritePlants()
    func getNewGardenPlantFromFavouritePlant()
}

//MARK: Controller for UserGardenView
class UserGardenController {
    weak var delegate: UserGardenControllerDelegate?
    var provider: UserGardenProviderProtocol
    var favouritePlants: [FavouritePlant]!
    var gardenPlants: [GardenPlant]!
    var gardenPlant: GardenPlant!
    let dataManager = CoreDataPlant()
    
    init(delegate: UserGardenControllerDelegate, provider: UserGardenProviderProtocol = UserGardenProvider()) {
        self.delegate = delegate
        self.provider = provider
        #if DEBUG
        if MockManagerSingleton.shared.runAppWithMock {
            self.provider = UserGardenProviderMock()
        }
        #endif
    }
    
    //MARK: General methods
    
    //get array of FavouritePlant
    func getFavouritePlants() {
        Task {
            do {
                let favouritePlants = try await provider.getInformationAboutFavouritePlants()
                self.favouritePlants = favouritePlants
            } catch {
                self.favouritePlants = [FavouritePlant]()
            }
            delegate?.getInformationAboutFavouritePlants()
        }
    }
    
    // get array of GardenPlant
    func getGardenPlants() {
        Task {
            do {
                let gardenPlants = try await provider.getInformationAboutGardenPlants()
                self.gardenPlants = gardenPlants
            }catch {
                self.gardenPlants = [GardenPlant]()
            }
            delegate?.getInformationAboutGardenPlants()
        }
    }
    
    
    func getGardenPlantFromFavouritePlant(name: String, watered: IrrigationInformation) async throws -> GardenPlant {
        //We tried to obtain the plant from Core Data
        if let gardenPlant = isThePlantInTheCoreData(name: name, watered: watered) {
            print("It was ready in coreData")
            return gardenPlant
        }
       
        // If it is not found in Core Data, we search in API
            do {
                defer {
                    delegate?.getNewGardenPlantFromFavouritePlant()
                }
                let suggestetPlantsName = try await provider.getNewPlantByText(name)
                var suggestetPlant = suggestetPlantsName.first!
                for index in 0 ..< suggestetPlantsName.count {
                    if suggestetPlantsName[index].plantName == name {
                        suggestetPlant = suggestetPlantsName[index]
                        break
                    }
                }
                
                //let suggestetPlant = suggestetPlantsName.first!
                let gardenPlant = try await provider.getGardenPlantInformation(suggestetPlant.accessToken, name: suggestetPlant.plantName, watered: watered)
                //self.gardenPlant = gardenPlant
                return gardenPlant
            }catch {
                print("plant could not be found")
                throw NetworkError.generic
            }
    }
    
    //Check if the plant was in CoreData
    private func isThePlantInTheCoreData(name: String, watered: IrrigationInformation) -> GardenPlant? {
        var gardenPlant: GardenPlant? = nil
        let plantsEntity = dataManager.fetchPlants()
        for index in 0 ..< plantsEntity.count {
            if plantsEntity[index].name == name {
                let plantEntity = plantsEntity[index]
                gardenPlant = convertPlantEntityModelToGardenPlant(plantEntity, watered: watered)
                break
            }
        }
        return gardenPlant
    }
    
    
    private func convertPlantEntityModelToGardenPlant(_ plantEntity: PlantEntity, watered: IrrigationInformation) -> GardenPlant{
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
        
        //initialize a GardenPlant
        let gardenPlant = GardenPlant(plantInformation: plantInformation, watered: watered)
        return gardenPlant
    }
    
    
    //Attempting to save GardenPlants in CoreData
    func savePlantsInCoreData(_ plants: [GardenPlant]){
        guard CoreDataUtils.shared.savePlantsByImageSearch else {
            print("New plants are not saved in the history")
            return }
        
        plants.forEach { plant in
            var plantInformation = plant.plantInformation
            plantInformation.isAdded = true
            CoreDataUtils.shared.saveNewPlant(plantInformation, watered: plant.watered)
        }
    }
 
    //Convert GardenPlant array to GardenPlantCell array
    func getGardenPlantsCell(gardenPlants: [GardenPlant]) -> [[GardenPlantCell]] {
        var gardenPlantsCellArray = [[GardenPlantCell]]()
        guard gardenPlants.count != 0  else {
            return gardenPlantsCellArray
        }
        // get GardenPlantCell array
        let gardenPlantsCell = gardenPlantModelToGardenPlantCell(gardenPlants)
        let gardenPlantsCellSorted = gardenPlantsCell.sorted {$0.nextIrrigation < $1.nextIrrigation}
        gardenPlantsCellArray = [[gardenPlantsCellSorted.first!]]
        // Organizes the array into array arrays based on the nextIrrigation variable
        for index in 0 ..< gardenPlantsCellSorted.count {
            var flag = false
            var newIndexToArray = 0
            for indexArray in 0 ..< gardenPlantsCellArray.count {
                if gardenPlantsCellSorted[index].nextIrrigation.formatted(date: .numeric, time: .omitted) == gardenPlantsCellArray[indexArray].first!.nextIrrigation.formatted(date: .numeric, time: .omitted) {
                    flag = true
                    newIndexToArray = indexArray
                }
            }
            if flag {
                gardenPlantsCellArray[newIndexToArray].append(gardenPlantsCellSorted[index])
            } else{
                gardenPlantsCellArray.append([gardenPlantsCellSorted[index]])
            }
        }
        gardenPlantsCellArray[0].remove(at: 0)
        return gardenPlantsCellArray
    }
    
    //Convert GardenPlant model to GardenPlantCell
    private func gardenPlantModelToGardenPlantCell(_ gardenPlants: [GardenPlant]) -> [GardenPlantCell] {
        var  gardenPlantsCell = [GardenPlantCell]()
        gardenPlants.forEach { gardenPlant in
            let name = gardenPlant.plantInformation.name
            let quantityOfWater = Int(gardenPlant.watered.waterAmount)
            let image = gardenPlant.plantInformation.details.image?.url ?? Constants.imagePlant
            let irrigationStatus = checkIrrigationStatus(gardenPlant.watered)
            let nextIrrigation = gardenPlant.watered.nextIrrigation
            let gardenPlantCell = GardenPlantCell(name: name, quantityOfWater: quantityOfWater, image: image, irrigationStatus: irrigationStatus, nextIrrigation: nextIrrigation)
            gardenPlantsCell.append(gardenPlantCell)
        }
        return gardenPlantsCell
    }
    
    //Determining the IrrigationStatus based on IrrigationInformation
    private func checkIrrigationStatus(_ watered: IrrigationInformation) -> IrrigationStatus {
        // get one of the three options
        guard watered.nextIrrigation >= Date.now else {
            return IrrigationStatus.dry
        }
        let midPoint: Int = -Int(watered.numberOfDays/2)
        let averageDate: Date = Calendar.current.date(byAdding: .day, value: midPoint, to: watered.nextIrrigation)!
        guard averageDate >= Date.now else {
            return IrrigationStatus.wet
        }
        return IrrigationStatus.watered
    }
    
    //conver models
    func convertGardenPlantModelToSuggestedPlant(_ model: GardenPlant) -> SuggestedPlant{
        //get Data
        let name = model.plantInformation.name
        let similarImages = model.plantInformation.similarImages
        let details = model.plantInformation.details
        let probability = Double.random(in: 0 ... 1)
        let id = model.plantInformation.name + String(probability)
        // get new suggestedPlant 
        let suggestedPlant = SuggestedPlant(id: id, name: name, probability: probability, similarImages: similarImages, details: details)
        return suggestedPlant
    }
    
    //get FavouritePlant array without plants with specific name
    func getNewFavouritePlants(without names: [String], andAdd oldFavouritePlants: [FavouritePlant]) -> [FavouritePlant] {
        //get the FavouritePlant array
        var favouritePlants = [FavouritePlant]()
        var plants = dataManager.fetchPlants()
        //delete the plants with the specific name
        names.forEach { name in
            plants.removeAll { plantEntity in
                plantEntity.name == name || plantEntity.isAdded == false
            }
        }
        //conver the plantEntity model to FavouritePlant
        plants.forEach { plantEntity in
            let detailsEntity = dataManager.fetchPlantDetails(plant: plantEntity)
            let wateredDetails = Watered(max: Int(detailsEntity!.wateringMax), min: Int(detailsEntity!.wateringMin))
            let image = detailsEntity?.descriptionImageUrl == nil ? Constants.imagePlant : (detailsEntity?.descriptionImageUrl)!
            let newFavouritePlant = FavouritePlant(name: plantEntity.name!, image: image, min: wateredDetails.min, max: wateredDetails.max)
            favouritePlants.append(newFavouritePlant)
        }
        
        //eliminating repetitive plants
        var totalFavouritePlants = favouritePlants
        let favouritePlantNames = Set(favouritePlants.map({ $0.name }))
        
        for plant in  oldFavouritePlants {
            if !favouritePlantNames.contains(plant.name) {
                totalFavouritePlants.append(plant)
            }
        }
        
        return totalFavouritePlants
    }
    
   
}



