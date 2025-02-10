//
//  UserGardenProviderMock.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import Foundation
class UserGardenProviderMock: UserGardenProviderProtocol {
    //MARK: Methods of UserGardenProviderProtocol
    func getNewPlantByText(_ text: String) async throws -> [SuggestedPlantName] {
        //get info from  mock .json
        guard let model = Utils.parseJson(jsonName: "FavouritePlantsUsingTextSearch", model: SimilarPlantsName.self) else{
            throw NetworkError.jsonDecoder
        }
        //Result obtained from .json
        let suggestedPlantsName = model.entities
        return suggestedPlantsName
    }
    
    func getGardenPlantInformation(_ accessToken: String, name: String, watered: IrrigationInformation) async throws -> GardenPlant {
        //get info from  mock .json
        guard let model = Utils.parseJson(jsonName: "FavouritePlantsNameMock", model: SimilarPlants.self) else{
            print("Could not be converted")
            throw NetworkError.jsonDecoder
        }
        //convert data
        let suggestedPlants = model.result.classification.suggestedPlants
        var indexPlant = 0
        for index in 0 ..< suggestedPlants.count {
            if suggestedPlants[index].name == name {
                indexPlant = index
                break
            }
        }
        let suggestedPlant = suggestedPlants[indexPlant]
        let plantInformation = PlantInformation(name: suggestedPlant.name, similarImages: suggestedPlant.similarImages, details: suggestedPlant.details)
        let gardenPlant = GardenPlant(plantInformation: plantInformation, watered: watered)
        
        return gardenPlant
    }
    
    
    func getInformationAboutGardenPlants() async throws -> [GardenPlant] {
        //get info from  mock .json
        guard let plantsForFirestore = Utils.parseJson(jsonName: "PlantsForFirestoreMock", model: PlantsForFirestore.self) else {
            print("Could not be converted")
            throw NetworkError.jsonDecoder
        }
        //convert data
        var result = [GardenPlant]()
        plantsForFirestore.elements.forEach { plantForFirestore in
            let (plantInformation, irrigationInformation) = FirestoreUtilts.shared.plantForFirestoreModelToPlantInformationModel(plantForFirestore)
            let item = GardenPlant(plantInformation: plantInformation, watered: irrigationInformation)
            result.append(item)
        }
        
        let updateResult = updateIrrigationInformation(gardenPlants: result)
        return updateResult
    }

    func getInformationAboutFavouritePlants() async throws -> [FavouritePlant] {
        //get info from  mock .json
        guard let favouriteplants = Utils.parseJson(jsonName: "FavouritePlantsMock", model: FavouritePlants.self) else {
            print("Could not be converted")
            throw NetworkError.jsonDecoder
        }
        let favouritePlantArray = favouriteplants.elements
        return favouritePlantArray
    }
    
    //MARK: General methods
    
    //update plant watering using today
    private func updateIrrigationInformation(gardenPlants: [GardenPlant]) -> [GardenPlant] {
        var result = [GardenPlant]()
        var index = 0
        
        //plant 1
        guard gardenPlants.count >= 1 else {return result }
        let today = Calendar.current.startOfDay(for: .now)
        let irrigationInformation1 = IrrigationInformation(numberOfDays: 7, waterAmount: 100, percentage: 8, wasItWatered: true, nextIrrigation: today)
        let gardenPlant1 = GardenPlant(plantInformation: gardenPlants[index].plantInformation, watered: irrigationInformation1)
        result.append(gardenPlant1)
        index += 1
        
        //plant 2
        guard gardenPlants.count >= 2 else {return result}
        let dayLate = Calendar.current.date(byAdding: .day, value: -1, to: today)
        let irrigationInformation2 = IrrigationInformation(numberOfDays: 7, waterAmount: 100, percentage: 8, wasItWatered: true, nextIrrigation: dayLate!)
        let gardenPlant2 = GardenPlant(plantInformation: gardenPlants[index].plantInformation, watered: irrigationInformation2)
        result.append(gardenPlant2)
        index += 1
        
        //plants 3 and 4
        guard gardenPlants.count >= 4 else {return result}
        let inFiveDays = Calendar.current.date(byAdding: .day, value: 5, to: today)
        let irrigationInformation3 = IrrigationInformation(numberOfDays: 12, waterAmount: 150, percentage: 8, wasItWatered: true, nextIrrigation: inFiveDays!)
        let gardenPlant3 = GardenPlant(plantInformation: gardenPlants[index].plantInformation, watered: irrigationInformation3)
        let gardenPlant4 = GardenPlant(plantInformation: gardenPlants[index + 1].plantInformation, watered: irrigationInformation3)
        result.append(gardenPlant3)
        result.append(gardenPlant4)
        index += 2
        
        //The last plants
        guard gardenPlants.count >= 5 else {return result}
        let inOneWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)
        let irrigationInformationLast = IrrigationInformation(numberOfDays: 10, waterAmount: 200, percentage: 8, wasItWatered: true, nextIrrigation: inOneWeek!)
        for indexLast in index ..< gardenPlants.count {
            let gardenPlantLast = GardenPlant(plantInformation: gardenPlants[indexLast].plantInformation, watered: irrigationInformationLast)
            result.append(gardenPlantLast)
        }
        
        return result
    }
}

