//
//  SearchViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

//MARK: Delegate for SearchView
protocol SearchViewControllerDelegate: AnyObject {
    func getPlantsResultsPerImage()
}

//MARK: Controller for SearchView
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
    
    //MARK: General methods
    //get a model from the Provider
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
    
    //get random plants from the CoreData
    func getRandomPlants() -> [SuggestedPlant] {
        //Get the plants form the CoreData
        let plants = dataManager.fetchPlants()
        // Mix and convert the arrangement
        let randomPlantsEntity = plants.shuffled()
        let randomSuggestedPlants = convertPlantEntityModelToSuggestedPlant(randomPlantsEntity)
        return randomSuggestedPlants
    }
    
    //save User To Firestore Cloud
    func saveUserToFirestoreCloud(email: String, provider: String) async  {
        await makeMethodsForFirestoreCloud {
                await FirestoreAddData.shared.addUserToCloud(with: email, andProvider: provider)
            }
    }
    
    //MARK: auxiliary methods
    //Convert one model to another
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
