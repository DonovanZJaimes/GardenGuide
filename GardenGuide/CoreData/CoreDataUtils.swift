//
//  CoreDataUtils.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 13/09/24.
//

import Foundation

struct CoreDataUtils {
    static var shared = CoreDataUtils()
    var savePlantsByImageSearch: Bool = true
    let dataManager = CoreDataPlant()
    var resultForFavorites: ResultForFavorites?
    
    enum ResultForFavorites: String {
        case save = "The plant is saved on favorites of CoreData"
        case dontDelete = "The plant is on favorites, if you wanna to eliminate you need to do in your garden"
        case alreadySaved = "The plant is already selected among the favorites"
        case alreadyDelete = "The plant is already deleted among the favorites"
        case delete = "The plant is deleted on favorites of CoreData"
    }
   
    
    //MARK: Save Plants in CoreData
    //Save New Plants from diferents models
    public func saveNewPlants<T: Nameable>(_ model: [T], watered: [IrrigationInformation] = [Constants.irrigationInformation]) {
        //Get all the plants from CoreData
        let plantsEntity = dataManager.fetchPlants()
        var flag: Bool = false
        //update watered
        var newWatered = watered
        if model.count != watered.count {
            newWatered = [IrrigationInformation](repeating: Constants.irrigationInformation, count: model.count)
        }
        //Check if the plantsEntity is empty
        guard plantsEntity.count != 0 else {
            savePlantInformationModelOrSuggestedPlantModel(model.first!, watered: newWatered.first!)
            return
        }
        //Check if the plant has already been saved
        var indexWatered = 0
        model.forEach { plantModel in
            plantsEntity.forEach { plantEntity in
                if plantEntity.name == plantModel.name {
                    flag = true
                }
            }
            if !flag {
                savePlantInformationModelOrSuggestedPlantModel(plantModel, watered: newWatered[indexWatered])
            }
            indexWatered += 1
            flag = false
        }
        
        
    }
    
    //Save New Plant from diferents models
    public func saveNewPlant<T: Nameable>(_ model: T, watered: IrrigationInformation = Constants.irrigationInformation) {
        //Get all the plants from CoreData
        let plantsEntity = dataManager.fetchPlants()
        var flag: Bool = false
        
        //Check if the plantsEntity is empty
        guard plantsEntity.count != 0 else {
            savePlantInformationModelOrSuggestedPlantModel(model, watered: watered)
            return
        }
        
        //save or update a plant
        plantsEntity.forEach { plantEntity in
            if plantEntity.name == model.name {
               // if verifyWatered(plant: plantEntity){
                //if isNewWatered(plant: plantEntity, newWatered: watered) {
                if watered.numberOfDays != Constants.irrigationInformation.numberOfDays {
                    //update watered
                    updatePlantWatering(name: plantEntity.name!, watered: watered, UID: plantEntity.id)
                }
                
                flag = true
            }
        }
        if !flag {
            savePlantInformationModelOrSuggestedPlantModel(model, watered: watered)
        }
    }
    
    
    //Save plant according to its model
    private func savePlantInformationModelOrSuggestedPlantModel<T: Nameable>(_ model: T,  watered: IrrigationInformation){
        //Model PlantInformation
        if let plantInformation = model as? PlantInformation {
            //Save plant in CoreData
            dataManager.savePlant(plant: plantInformation, watered: watered)
        }
        //Model SuggestedPlant
        if let suggestedPlant = model as? SuggestedPlant {
            let plantInformation = convertSuggestedPlantModelToPlantInformationModel(suggestedPlant)
            //Save plant in CoreData
            dataManager.savePlant(plant: plantInformation, watered: watered)
        }
    }
    
    // //Convert one model to another
    private func convertSuggestedPlantModelToPlantInformationModel(_ plant: SuggestedPlant)-> PlantInformation{
        let name = plant.name
        let similarImages = plant.similarImages
        let details = plant.details
        let plantInformation = PlantInformation(name: name, isAdded: false, similarImages: similarImages, details: details)
        return plantInformation
    }
    
    //update plant watering on CoreData
    public func updatePlantWatering(name: String, watered: IrrigationInformation, UID: UUID? = nil) {
        guard UID == nil else {
            //using a UUID
            dataManager.modifyPlantWateringChanges(withUID: UID!, newIrrigation: watered)
            return
        }
        //Using a name
        let plantsEntity = dataManager.fetchPlants()
        plantsEntity.forEach { plantEntity in
            if plantEntity.name == name {
                dataManager.modifyPlantWateringChanges(withUID: plantEntity.id!, newIrrigation: watered)
            }
        }
    }
    
    
    //MARK: Add plant to favourites in CoreData
    //know if the plant will be added to favorites or not
    public func addPlantToFavorites(name: String, selectedForFavorites: Bool, callback: (ResultForFavorites)->Void) {
        var plantEntity: PlantEntity?
        //Get all the plants from CoreData
        let plantsEntity = dataManager.fetchPlants()
        //find the plant
        for index in stride(from: (plantsEntity.count - 1), through: 0, by: -1) {
            if plantsEntity[index].name == name {
                plantEntity = plantsEntity[index]
                break
            }
        }
        
        //Handling the case where the plant is not found
        guard let plant = plantEntity else {
            print("Planta no encontrada")
            return
        }
        
        //Check if the plant will be added to favorites or removed
        switch selectedForFavorites {
        case true:
            //Check the value of the plant
            switch plant.isAdded {
            case true:
                callback(ResultForFavorites.alreadySaved)
            case false:
                plant.isAdded = true
                Notifications.shared.newPlants.append("new plant")
                //Modify plant in CoreData
                dataManager.editPlantToFavorites(withUID: plant.id!, addedtofavorites: true)
                callback(ResultForFavorites.save)
            }
            break
        case false:
            //Check the value of the plant
            switch plant.isAdded {
            case true:
                //Check if the plant has already been modified.
                guard verifyWatered(plant: plant) else {
                    callback(ResultForFavorites.dontDelete)
                    print("jijii")
                    return
                }
                plant.isAdded = false
                callback(ResultForFavorites.delete)
                // notify that a plant has been removed
                if Notifications.shared.newPlants.count != 0 {
                    Notifications.shared.newPlants.removeLast()
                }
                //Modify plant in CoreData
                dataManager.editPlantToFavorites(withUID: plant.id!, addedtofavorites: false)
            case false:
                callback(ResultForFavorites.alreadyDelete)
            }
            break
        }
        Notifications.shared.newFavouritePlant.toggle()
        dataManager.save()
    }
    
    
    //Check if the watering of the plant has already been modified
    private func verifyWatered(plant: PlantEntity) -> Bool {
        let watered = dataManager.fetchWatered(plant: plant)
        let irrigation = IrrigationInformation(numberOfDays: -1, waterAmount: 0, percentage: 0, wasItWatered: false, nextIrrigation: Date.now)
        guard watered?.numberOfDays == irrigation.numberOfDays else {
            return false
        }
        return true
    }
    
    private func isNewWatered(plant: PlantEntity, newWatered: IrrigationInformation) -> Bool {
        let watered = dataManager.fetchWatered(plant: plant)
        if watered?.numberOfDays == newWatered.numberOfDays {
            return false
        } else {
            return true
        }
         
    }
    
    //MARK: Verification
    //Check if the plant is in favorites
    public func plantIsInFavorites<T: Nameable>(_ model: T) -> Bool{
        let plantsEntity = dataManager.fetchPlants()
        var isAdded = false
        //Check if the plantsEntity is empty
        guard plantsEntity.count != 0 else {
            return false
        }
        //Check if the plant is in favorites
        plantsEntity.forEach { plantEntity in
            if plantEntity.name == model.name {
                isAdded = plantEntity.isAdded
            }
        }
        return isAdded
    }
    
    
    //MARK: Delete Plants in CoreData
    //Delete a Plant with name in CoreData
    public func deletePlant(withName name: String) {
        //Get PlantEntity to delete
        let plantsEntity = dataManager.fetchPlants()
        var plantEntityToDelete: PlantEntity!
        plantsEntity.forEach { plantEntity in
            if name == plantEntity.name {
                plantEntityToDelete = plantEntity
            }
        }
        //delete plantEntity
        guard let plantEntityToDelete = plantEntityToDelete else {return}
        dataManager.deletePlant(plantEntityToDelete)
        
    }
    
    
}
