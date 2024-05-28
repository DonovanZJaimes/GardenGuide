//
//  SearchViewProvider.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

protocol SearchViewProviderProtocol {
    func getPlantsByImage(imageInBase64String: String) async throws -> PlantsByImageSearch
    func getPlantsByText(_ text: String) async throws -> [SuggestedPlantName]
    
} 
class SearchViewProvider: SearchViewProviderProtocol {
    func getPlantsByText(_ text: String) async throws -> [SuggestedPlantName] {
        let queryItem = ["q": text]
        let requestModel = RequestModel(endpoint: .plants, httpMethod: .GET, queryItems: queryItem, postData: nil)
        
        do {
            let model = try await ServiceLayer.callService(requestModel, SimilarPlantsName.self)
            let suggestedPlantsName = model.entities
            return suggestedPlantsName
            
            
        }catch {
            throw NetworkError.generic
        }
       
    }
    
    func getPlantsByImage(imageInBase64String: String) async throws -> PlantsByImageSearch {
        let parameters = "{\n    \"images\": [\"data:image/jpg;base64," + imageInBase64String + "\"],\n   \"similar_images\": true\n}"
        let postData = parameters.data(using: .utf8)
        let queryItem = ["details":"common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering,propagation_methods"]
        let requestModel = RequestModel(endpoint: .identification, httpMethod: .POST, queryItems: queryItem, postData: postData)
        
        do {
            let model = try await ServiceLayer.callService(requestModel, SimilarPlants.self)
            let isPlant = model.result.isPlant
            let suggestedPlants = model.result.classification.suggestedPlants
            let plantsByImageSearch = PlantsByImageSearch(isPlant: isPlant, suggestedPlants: suggestedPlants)
            return plantsByImageSearch
            
        } catch {
            throw NetworkError.generic
        }
        
    }
    
    func getPlantDetails(accessToken: String) async throws -> PlantDetails {
        let queryItem = ["details":"common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering,propagation_methods"]
        let requestModel = RequestModel(endpoint: .detail, httpMethod: .GET, queryItems: queryItem, extra: accessToken, postData: nil)
        
        do {
            let model = try await ServiceLayer.callService(requestModel, PlantDetails.self)
            return model
        } catch {
            throw NetworkError.generic
        }
    }
}
