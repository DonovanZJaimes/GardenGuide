//
//  SearchViewProviderMock.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

//MARK: Provider to get information to the Mock
class SearchViewProviderMock: SearchViewProviderProtocol {
    //Get an array SuggestedPlantName model from the Mock
    func getPlantsByText(_ text: String) async throws -> [SuggestedPlantName] {
        //Get data with mock .json
        guard let model = Utils.parseJson(jsonName: "PlantNameResultsUsingTextSearch", model: SimilarPlantsName.self) else{
            print("Could not be converted")
            throw NetworkError.jsonDecoder
        }
        let suggestedPlantsName = model.entities
        return suggestedPlantsName
    }
    
    //Get a PlantsByImageSearch model from the Mock
    func getPlantsByImage(imageInBase64String: String) async throws -> PlantsByImageSearch {
        //Get data with mock .json
        guard let model = Utils.parseJson(jsonName: "PlantResultsByImageSearch", model: SimilarPlants.self) else{
            print("Could not be converted")
            throw NetworkError.jsonDecoder
        }
        let isPlant = model.result.isPlant
        let suggestedPlants = model.result.classification.suggestedPlants
        let plantsByImageSearch = PlantsByImageSearch(isPlant: isPlant, suggestedPlants: suggestedPlants)
        
        return plantsByImageSearch
    }
    
    //Get a PlantDetails model from the Mock
    func getPlantDetails(accessToken: String) async throws -> PlantDetails {
        //Get data with mock .json
        guard let model = Utils.parseJson(jsonName: "??", model: PlantDetails.self) else{
            print("Could not be converted")
            throw NetworkError.jsonDecoder
        }
        return model
        
    }
    
}
