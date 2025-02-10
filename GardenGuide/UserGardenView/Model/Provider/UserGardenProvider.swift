//
//  UserGardenProvider.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import Foundation
class UserGardenProvider: UserGardenProviderProtocol {
    let dataManager = CoreDataPlant()
    //MARK: Methods of UserGardenProviderProtocol
    func getGardenPlantInformation(_ accessToken: String, name: String, watered: IrrigationInformation) async throws -> GardenPlant {
        //initializing a request model
        let queryItem = ["details":"common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering,propagation_methods"]
        let requestModel = RequestModel(endpoint: .detail, httpMethod: .GET, queryItems: queryItem, extra: accessToken, postData: nil)
        do {
            //get GardenPlant from API
            let model = try await ServiceLayer.callService(requestModel, PlantDetails.self)
            let plantInformation = PlantInformation(name: name, similarImages: nil, details: model)
            let gardenPlant = GardenPlant(plantInformation: plantInformation, watered: watered)
            return gardenPlant
        } catch {
            throw NetworkError.generic
        }
    }
    
    func getNewPlantByText(_ text: String) async throws -> [SuggestedPlantName] {
        //initializing a request model
        let queryItem = ["q": text]
        let requestModel = RequestModel(endpoint: .plants, httpMethod: .GET, queryItems: queryItem, postData: nil)
        do {
            //Get the plant result list from API
            let model = try await ServiceLayer.callService(requestModel, SimilarPlantsName.self)
            let suggestedPlantsName = model.entities
            return suggestedPlantsName
        }catch {
            throw NetworkError.generic
        }
    }
    
    func getInformationAboutGardenPlants() async throws -> [GardenPlant] {
        var plantsForFirestore = [PlantForFirestore]()
        var result = [GardenPlant]()
        await makeMethodsForFirestoreCloud {
            do {
                //get GardenPlant array from Firestore Cloud
                plantsForFirestore = try await FirestoreGetData.shared.getGardenPlantsToCloud()
                plantsForFirestore.forEach { plantForFirestore in
                    let (plantInformation, irrigationInformation) = FirestoreUtilts.shared.plantForFirestoreModelToPlantInformationModel(plantForFirestore)
                    let item = GardenPlant(plantInformation: plantInformation, watered: irrigationInformation)
                    result.append(item)
                }
                
            }catch {
                plantsForFirestore = []
            }
        }
        //add new gardenPlants from CoreData
        let totalGardenPlants = addMoreGardenPlantsWithCoreData(andFirestore: result)
        return totalGardenPlants
    }
    
    func getInformationAboutFavouritePlants() async throws -> [FavouritePlant] {
        var favouritePlantsInFirestore = [FavouritePlantInFirestore]()
        await makeMethodsForFirestoreCloud {
            do {
                //get FavouritePlant array from Firestore Cloud
                favouritePlantsInFirestore = try await FirestoreGetData.shared.getPlantsOfFavouritesToCloud()
            }catch {
                favouritePlantsInFirestore = []
            }
        }
        
        //add new favouritePlants from CoreData
        let favouritePlants = favouritePlantsInFirestore.map { FavouritePlant(name: $0.name, image: $0.image, min: $0.min, max: $0.max) }
        let totalFavouritePlants = addMoreFavouritePlantsWithCoreData(andFirestore: favouritePlants)
        return totalFavouritePlants
        
    }
    
    //MARK: General methods
   
    private func addMoreGardenPlantsWithCoreData(andFirestore gardenPlants: [GardenPlant]) -> [GardenPlant]{
        var totalGardenPlants: [GardenPlant] = gardenPlants
        //let dataManager = CoreDataPlant()
        let plantsEntity = dataManager.fetchPlants()
        for index in 0 ..< plantsEntity.count {
            // verify that the plants in CoreData are in GardenPlants
            let plantEntity = plantsEntity[index]
            let watered = dataManager.fetchWatered(plant: plantEntity)
            guard watered?.numberOfDays != -1 || watered?.waterAmount != 0 else {continue }
            // check if the plant is already in GardenPlants of Firestore
            var newPlant = true
            for indexPlant in 0 ..< gardenPlants.count {
                if gardenPlants[indexPlant].plantInformation.name == plantEntity.name {
                    newPlant = false
                    break
                }
            }
            // add new GardenPlant
            guard newPlant else {continue}
            let newGardenPlant = convertPlantEntityModelToGardenPlant(plantEntity, dataManager: dataManager)
            totalGardenPlants.append(newGardenPlant)
        }
        return totalGardenPlants
    }
    
    
    private func convertPlantEntityModelToGardenPlant(_ plantEntity: PlantEntity, dataManager: CoreDataPlant) -> GardenPlant {
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
        
        //get watered
        let watered = dataManager.fetchWatered(plant: plantEntity)
        let irrigationInformation = IrrigationInformation(numberOfDays: watered!.numberOfDays, waterAmount: watered!.waterAmount, percentage: watered!.percentage, wasItWatered: watered!.wasItWatered, nextIrrigation: (watered?.nextIrrigation)!)
        
        
        let gardenPlant = GardenPlant(plantInformation: plantInformation, watered: irrigationInformation)
        return gardenPlant
    }
    
    private func addMoreFavouritePlantsWithCoreData(andFirestore favouritePlants: [FavouritePlant]) -> [FavouritePlant] {
        var totalFavouritePlants: [FavouritePlant] = favouritePlants
        let plantsEntity = dataManager.fetchPlants()
        for index in 0 ..< plantsEntity.count {
            // verify that the plants in CoreData are in FavouritePlants
            let plantEntity = plantsEntity[index]
            let watered = dataManager.fetchWatered(plant: plantEntity)
            guard (watered?.numberOfDays == -1 || watered?.waterAmount == 0) && (plantEntity.isAdded) else {continue }
            // check if the plant is already in FavouritePlants of Firestore
            var newPlant = true
            for indexPlant in 0 ..< favouritePlants.count {
                if favouritePlants[indexPlant].name == plantEntity.name {
                    newPlant = false
                    break
                }
            }
            // add new FavouritePlant
            guard newPlant else {continue}
            let newFavouritePlant = convertPlantEntityModelToFavouritePlant(plantEntity)
            totalFavouritePlants.append(newFavouritePlant)
        }
        return totalFavouritePlants
    }
    
    private func convertPlantEntityModelToFavouritePlant(_ plantEntity: PlantEntity) -> FavouritePlant {
        let detailsEntity = dataManager.fetchPlantDetails(plant: plantEntity)
        let name = plantEntity.name
        let max: Int = Int(detailsEntity?.wateringMax ?? 1)
        let min: Int = Int(detailsEntity?.wateringMin ?? 1)
        let image = detailsEntity?.descriptionImageUrl ?? Constants.imagePlant
        let favouritePlant = FavouritePlant(name: name!, image: image, min: min, max: max)
        return favouritePlant
    }
}



