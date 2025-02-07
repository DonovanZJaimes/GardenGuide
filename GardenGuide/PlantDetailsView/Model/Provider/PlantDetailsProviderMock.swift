//
//  PlantDetailsProviderMock.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/06/24.
//

import Foundation

//MARK: Provider to get information to the Mock
class PlantDetailsProviderMock: PlantDetailsProviderProtocol {
    //Get a PlantInformation model from the Mock
    func getPlantInformation(_ accessToken: String, name: String) async throws -> PlantInformation {
        guard let model = Utils.parseJson(jsonName: "PlantInformationMock", model: SuggestedPlant.self) else{
            throw NetworkError.jsonDecoder
        }
        //Result obtained from .json
        let name = model.name
        let similarImages = model.similarImages
        let details = model.details
        let plantInformation = PlantInformation(name: name, similarImages: similarImages, details: details)
        return plantInformation
    }
    
    
}
