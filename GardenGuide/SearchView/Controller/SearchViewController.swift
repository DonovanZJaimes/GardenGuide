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
    let dataManager = CoreDataPlant()
    
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
    
    func getRandomPlants() -> [SuggestedPlant] {
        let plants = dataManager.fetchPlants()
        var plantsEntity: [PlantEntity] = [plants[(plants.count - 1)]]
        //add 50 plants maximum
        for index in stride(from: (plants.count - 1), through: 0, by: -1) {
            if index == 50 {
                break
            }
            //add plants without repeating them
            var flag = true
            plantsEntity.forEach { plantEntity in
                if plantEntity.name == plants[index].name {
                    flag = false
                }
                
            }
            if flag {
                plantsEntity.append(plants[index])
            }
        }
        
        // Mix and convert the arrangement
        let randomPlantsEntity = plantsEntity.shuffled()
        let randomSuggestedPlants = convertPlantEntityModelToSuggestedPlant(randomPlantsEntity)
        return randomSuggestedPlants
    }
    
    func convertPlantEntityModelToSuggestedPlant(_ plantsEntity: [PlantEntity]) -> [SuggestedPlant]{
        var suggestedPlants = [SuggestedPlant]()
        for index in 0 ..< plantsEntity.count {
            let plantEntity = plantsEntity[index]
            
            //Get a  [SimilarImage]
            let similarImagesEntity = dataManager.fetchSimilarImages(plant: plantEntity)
            var similarImages = [SimilarImage]()
            similarImagesEntity.forEach { similarImageEntity in
                let similarImage = SimilarImage(id: similarImageEntity.id!, url: similarImageEntity.url!, similarity: similarImageEntity.similarity, image: similarImageEntity.image)
                similarImages.append(similarImage)
            }
            
            //Get different [String]?  features
            let detailsEntity = dataManager.fetchPlantDetails(plant: plantEntity)
            let commonNames = dataManager.fetchCommonNames(plantDetails: detailsEntity!)
            let synonyms = dataManager.fetchSynonyms(plantDetails: detailsEntity!)
            let edibleParts = dataManager.fetchEdibleParts(plantDetails: detailsEntity!)
            let propagationMethods = dataManager.fetchPropagationMethods(plantDetails: detailsEntity!)
            let watered = Watered(max: Int(detailsEntity!.wateringMax), min: Int(detailsEntity!.wateringMin))
            
            //Get different description values
            let description = detailsEntity?.descriptionUrl == nil ? nil : PlantDetails.Description(value: (detailsEntity?.descriptionValue)! , url: (detailsEntity?.descriptionUrl)!)
            let descriptionImage = detailsEntity?.descriptionImageUrl == nil ? nil : PlantDetails.DescriptionImage(url: (detailsEntity?.descriptionImageUrl)!, image: detailsEntity?.escriptionImage)
            
            //initialize a  PlantDetails
            let plantDetails = PlantDetails(commonNames: commonNames, url: detailsEntity?.url, rank: detailsEntity?.rank, description: description, synonyms: synonyms, image: descriptionImage, edibleParts: edibleParts, watering: watered, propagationMethods: propagationMethods)
            
            //initialize and add  a SuggestedPlant
            let suggestedPlant = SuggestedPlant(id: String(index), name: plantEntity.name! , probability: Double(index), similarImages: similarImages, details: plantDetails)
            suggestedPlants.append(suggestedPlant)
        }
        return suggestedPlants
    }
    

    
}
