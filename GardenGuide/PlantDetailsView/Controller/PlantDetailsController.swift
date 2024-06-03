//
//  PlantDetailsController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/06/24.
//

import Foundation
protocol PlantDetailsControllerDelegate: AnyObject {
    func obtainedPlantInformation()
}

 @MainActor class PlantDetailsController {
    var plantInformation: PlantInformation!
    var provider: PlantDetailsProviderProtocol
    weak var delegate: PlantDetailsControllerDelegate?
    
    init(provider: PlantDetailsProviderProtocol = PlantDetailsProvider(), delegate: PlantDetailsControllerDelegate) {
        self.provider = provider
        self.delegate = delegate
        #if DEBUG
        if MockManagerSingleton.shared.runAppWithMock {
            self.provider = PlantDetailsProviderMock()
        }
        #endif
    }
    
    func getPlantInformation(accessToken: String, name: String) async  {
        do {
            let plantInformation = try await provider.getPlantInformation(accessToken, name: name)
            self.plantInformation = plantInformation
            delegate?.obtainedPlantInformation()
        }catch {
            print(error)
        }
    }
    
    func getPlantInformationWithSuggestedPlant(_ suggestedPlant: SuggestedPlant) {
        let name = suggestedPlant.name
        let similarImages = suggestedPlant.similarImages
        let details = suggestedPlant.details
        self.plantInformation = PlantInformation(name: name, similarImages: similarImages, details: details)
        delegate?.obtainedPlantInformation()
    }
    
}
