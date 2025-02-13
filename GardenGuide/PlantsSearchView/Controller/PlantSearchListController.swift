//
//  PlantSearchListController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 28/05/24.
//

import Foundation
//MARK: Delegate form PlantSearchListController
protocol PlantSearchListControllerDelegate: AnyObject {
    func getListOfPlantNamesByText()
}

//MARK: Controller of PlantSearchView
@MainActor class PlantSearchListController {
    var provider: PlantSearchListProviderProtocol
    weak var delegate: PlantSearchListControllerDelegate?
    var plantsResults = [SuggestedPlantName]()
    
    init(provider: PlantSearchListProviderProtocol = PlantSearchListProvider(), delegate: PlantSearchListControllerDelegate) {
        self.provider = provider
        self.delegate = delegate
        #if DEBUG
        if MockManagerSingleton.shared.runAppWithMock {
            self.provider = PlantSearchListProviderMock()
        }
        #endif
    }
    
    //MARK: General methods
    
    func lookForPlants(word: String)  {
        Task {
            do {
                //Get plant result list
                let plantsList = try await provider.getPlantsByText(word)
                plantsResults = plantsList
                //Indicate that the list is already ready
                delegate?.getListOfPlantNamesByText()
            }
            catch {
                print(error)
            }

        }
    }
    
   
    
}
