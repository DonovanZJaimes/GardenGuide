//
//  SearchViewProviderMock.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

class SearchViewProviderMock: SearchViewProviderProtocol {
    func getPlantsByText(_ text: String) async throws -> [SuggestedPlantName] {
        guard let model = Utils.parseJson(jsonName: "PlantNameResultsUsingTextSearch", model: SimilarPlantsName.self) else{
            print("No se pudo convertir")
            throw NetworkError.jsonDecoder
        }
        let suggestedPlantsName = model.entities
        return suggestedPlantsName
    }
    
    func getPlantsByImage(imageInBase64String: String) async throws -> PlantsByImageSearch {
        guard let model = Utils.parseJson(jsonName: "PlantResultsByImageSearch", model: SimilarPlants.self) else{
            print("No se pudo convertir")
            throw NetworkError.jsonDecoder
        }
        let isPlant = model.result.isPlant
        let suggestedPlants = model.result.classification.suggestedPlants
        let plantsByImageSearch = PlantsByImageSearch(isPlant: isPlant, suggestedPlants: suggestedPlants)
        
        return plantsByImageSearch
    }
    
    func getPlantDetails(accessToken: String) async throws -> PlantDetails {
        guard let model = Utils.parseJson(jsonName: "??", model: PlantDetails.self) else{
            print("No se pudo convertir")
            throw NetworkError.jsonDecoder
        }
        return model
        
    }
    
}
