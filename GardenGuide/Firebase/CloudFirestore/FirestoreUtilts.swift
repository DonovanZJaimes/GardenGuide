//
//  FirestoreUtilts.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/10/24.
//

import Foundation

struct FirestoreUtilts {
    //Constants of collections in Cloud Firestore
    static var userEmail = ""
    static var userProvider : ProviderType = .none
    static var shared =  FirestoreUtilts()
    static let collectionUsers = "users"
    static let collectionFavouritePlants = "FavouritePlants"
    static let collectionGardenPlants = "GardenPlants"
    static let collectionSimilarImage = "SimilarImage"
    static let collectionIrrigationInformation = "IrrigationInformation"
    static let collectionDetailsInformation = "DetailsInformation"
}

extension FirestoreUtilts {
    //MARK: Change the user information in the application
    mutating func modifyUserEmail(_ email: String){
        FirestoreUtilts.userEmail = email
    }
    mutating func modifyUserProvider(_ provider: String){
        guard let providerType = ProviderType.init(rawValue: provider) else  { return}
        FirestoreUtilts.userProvider = providerType
    }
    
    //MARK: Methods for changing from one model to another
    
    //PlantInformation To PlantForFirestore
    public func plantInformationModelToPlantForFirestoreModel(_ plant: PlantInformation, watered: IrrigationInformation) -> PlantForFirestore {
        let name = plant.name
        let isAdded = true
        let similarImages = plant.similarImages
        let details = plantDetailsModelToPlantDetailsFirestoreModel(plant.details)
        let watered = watered
        let plantForFirestore = PlantForFirestore(name: name, isAdded: isAdded, similarImages: similarImages, details: details, watered: watered)
        return plantForFirestore
    }
    
    //PlantForFirestore To PlantInformation
    public func plantForFirestoreModelToPlantInformationModel(_ plant: PlantForFirestore) -> (PlantInformation, IrrigationInformation){
        //IrrigationInformation
        let irrigationInformation = plant.watered
        //PlantDetails
        let name = plant.name
        let isAdded = true
        let similarImages = plant.similarImages
        let details = plantDetailsFirestoreModelToPlantDetailsModel(plant.details)
        let plantInformation = PlantInformation(name: name, isAdded: isAdded, similarImages: similarImages, details: details)
       return (plantInformation, irrigationInformation)
    }
    
    //PlantDetails To PlantDetailsFirestore
    private func plantDetailsModelToPlantDetailsFirestoreModel(_ model: PlantDetails) -> PlantDetailsFirestore {
        let plantDetailsFirestore = PlantDetailsFirestore(commonNames: model.commonNames, url: model.url, rank: model.rank, descriptionUrl: model.description?.url, descriptionValue: model.description?.value, synonyms: model.synonyms, imageUrl: model.image?.url, edibleParts: model.edibleParts, wateringMax: model.watering?.max, wateringMin: model.watering?.min, propagationMethods: model.propagationMethods)
        return plantDetailsFirestore
    }
    
    //PlantDetailsFirestore To PlantDetails
    private func plantDetailsFirestoreModelToPlantDetailsModel(_ model: PlantDetailsFirestore) -> PlantDetails {
        var description = PlantDetails.Description(value: "", url: "")
        var image = PlantDetails.DescriptionImage(url: "", image: nil)
        if let value = model.descriptionValue, let url = model.descriptionUrl, let imageUrl = model.imageUrl {
            description = PlantDetails.Description(value: value, url: url)
            image = PlantDetails.DescriptionImage(url: imageUrl, image: nil)
        }
        let watered = Watered(max: model.wateringMax ?? 0, min: model.wateringMin ?? 0)
        let plantDetails = PlantDetails(commonNames: model.commonNames, url: model.url, rank: model.rank, description: description, synonyms: model.synonyms, image: image, edibleParts: model.edibleParts, watering: watered, propagationMethods: model.propagationMethods)
        return plantDetails
    }
    
}


//MARK: Method to know if Firestore Cloud can be used
public func makeMethodsForFirestoreCloud(callback: @escaping () async ->Void ) async {
    let userProvider = FirestoreUtilts.userProvider
    guard userProvider != ProviderType.anonymous && userProvider != ProviderType.none else {
        print("You need to hava an account to save the plant on Firestore")
        return }
    await callback()
}
