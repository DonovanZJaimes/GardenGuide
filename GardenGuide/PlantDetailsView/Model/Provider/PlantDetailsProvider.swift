//
//  PlantDetailsProvider.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/06/24.
//

import Foundation
protocol PlantDetailsProviderProtocol {
    func getPlantInformation(_ accessToken: String, name: String) async throws -> PlantInformation
}

//MARK: Provider to get information to the API
class PlantDetailsProvider: PlantDetailsProviderProtocol {
    //Get a PlantInformation model from the API
    func getPlantInformation(_ accessToken: String, name: String) async throws -> PlantInformation {
        let queryItem = ["details":"common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering,propagation_methods"]
        let requestModel = RequestModel(endpoint: .detail, httpMethod: .GET, queryItems: queryItem, extra: accessToken, postData: nil)
        
        do {
            let model = try await ServiceLayer.callService(requestModel, PlantDetails.self)
            let plantInformation = PlantInformation(name: name, similarImages: nil, details: model)
            return plantInformation
        } catch {
            throw NetworkError.generic
        }
    }
    
    
}
