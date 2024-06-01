//
//  PlantSearchListProvider.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 28/05/24.
//

import Foundation

//MARK: Protocol for the Provider
protocol PlantSearchListProviderProtocol {
    func getPlantsByText(_ text: String) async throws -> [SuggestedPlantName]
}

//MARK: Provider for the plant search list
class PlantSearchListProvider: PlantSearchListProviderProtocol {
    func getPlantsByText(_ text: String) async throws -> [SuggestedPlantName] {
        //initializing a request model
        let queryItem = ["q": text]
        let requestModel = RequestModel(endpoint: .plants, httpMethod: .GET, queryItems: queryItem, postData: nil)
        do {
            //Get the plant result list
            let model = try await ServiceLayer.callService(requestModel, SimilarPlantsName.self)
            let suggestedPlantsName = model.entities
            return suggestedPlantsName
        }catch {
            throw NetworkError.generic
        }
    }
    
    
}
