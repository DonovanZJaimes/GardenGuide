//
//  PlantSearchListProviderMock.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 28/05/24.
//

import Foundation

//MARK: Provider Mock for the plant search list
class PlantSearchListProviderMock: PlantSearchListProviderProtocol {
    func getPlantsByText(_ text: String) async throws -> [SuggestedPlantName] {
        guard let model = Utils.parseJson(jsonName: "PlantNameResultsUsingTextSearch", model: SimilarPlantsName.self) else{
            throw NetworkError.jsonDecoder
        }
        //Result obtained from .json
        let suggestedPlantsName = model.entities
        return suggestedPlantsName
    }
    
    
}
