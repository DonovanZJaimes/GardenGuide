//
//  SearchViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

protocol SearchViewControllerDelegate: AnyObject {
    func getPlantsResultsPerImage()
}

@MainActor class SearchViewController {
    var provider: SearchViewProviderProtocol
    weak var delegate: SearchViewControllerDelegate?
    
    var plantResults : PlantsByImageSearch!
    
    init(provider: SearchViewProviderProtocol = SearchViewProvider(), delegate: SearchViewControllerDelegate) {
        self.provider = provider
        self.delegate = delegate
        #if DEBUG
        if MockManagerSingleton.shared.runAppWithMock {
            self.provider = SearchViewProviderMock()
        }
        #endif
    }
    
    func getPlantsByImage(imageInBase64String: String) async {
        do {
            let plants = try await provider.getPlantsByImage(imageInBase64String: imageInBase64String)
            plantResults = plants
            delegate?.getPlantsResultsPerImage()
        }
        catch {
            print(error)
        }
    }
    
    
}
