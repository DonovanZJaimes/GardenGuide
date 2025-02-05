//
//  FirestoreAddData.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 28/09/24.
//

import Foundation
import FirebaseFirestore

struct FirestoreAddData {
    //Cloud Firestore
    static var shared =  FirestoreAddData()
    private let db = Firestore.firestore()
    private var firestoreUtilts = FirestoreUtilts()
    private let CoUser = FirestoreUtilts.collectionUsers
    private let CoFavPlants = FirestoreUtilts.collectionFavouritePlants
    private let CoGarPlants = FirestoreUtilts.collectionGardenPlants
    private let CoSimImage = FirestoreUtilts.collectionSimilarImage
    private let CoIrrInfo = FirestoreUtilts.collectionIrrigationInformation
    private let CoDetInfo = FirestoreUtilts.collectionDetailsInformation
    
    //MARK: Methods for storing user information in the Firestore Cloud
    
    //Saving user
    mutating func addUserToCloud(with email: String, andProvider provider: String) async {
        do {
            try await db.collection(CoUser).document(email).setData([
            "provider": provider
        ])
            print("user save on Firestore Cloud")
            firestoreUtilts.modifyUserEmail(email)
        } catch {
          print("Error adding user: \(error)")
        }
    }
    
    //Saving favourite plants of the user
    func addPlantOfFavouritesToCloud(_ plant: FavouritePlant) async {
        do {
            //save name and image of plant
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoFavPlants).document(plant.name).setData([
                "name" : plant.name,
                "image" : plant.image,
                "min" : plant.min,
                "max" : plant.max
            ])
            print("save plant on Firestore Cloud")
        } catch {
          print("Error adding user plant: \(error)")
        }
    }
    
    //Saving garden plants of the user
    func addGardenPlantToCloud(_ plant: PlantForFirestore) async {
        let emptyArray = [""]
        do {
            //save name of the plant
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(plant.name).setData([
                "name" : plant.name,
                "isAdded" : plant.isAdded
            ])
            
            //save plant details
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(plant.name).collection(CoDetInfo).document(CoDetInfo).setData([
                "commonNames" : (plant.details.commonNames ?? emptyArray),
                "url" : (plant.details.url ?? ""),
                "rank" : (plant.details.rank ?? ""),
                "descriptionValue" : (plant.details.descriptionValue ?? ""),
                "descriptionUrl" : (plant.details.descriptionUrl ?? ""),
                "synonyms" : (plant.details.synonyms ?? emptyArray),
                "imageUrl" : (plant.details.imageUrl ?? ""),
                "edibleParts" : (plant.details.edibleParts ?? emptyArray),
                "wateringMax" : (plant.details.wateringMax ?? 0),
                "wateringMin" : (plant.details.wateringMin ?? 0),
                "propagationMethods" : (plant.details.propagationMethods ?? emptyArray)
                
            ])
            //Save similar images of the plant
            if let similarImages = plant.similarImages, similarImages.count >= 1 {
                for index in 1 ... similarImages.count {
                    let documentSimilarImage = CoSimImage + String(index)
                    try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(plant.name).collection(CoSimImage).document(documentSimilarImage).setData([
                        "id" : similarImages[index - 1].id,
                        "url" : similarImages[index - 1].url,
                        "similarity" :  similarImages[index - 1].similarity
                    
                    ])
                }
            }
            //Save the irrigation information of the plant
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(plant.name).collection(CoIrrInfo).document(CoIrrInfo).setData([
                "numberOfDays" : plant.watered.numberOfDays,
                "waterAmount" : plant.watered.waterAmount,
                "percentage" : plant.watered.percentage,
                "wasItWatered" : plant.watered.wasItWatered,
                "nextIrrigation" : plant.watered.nextIrrigation
            ])
            
            print("save garden plant on Firestore Cloud")
        } catch {
          print("Error save garden plant: \(error)")
        }
    }
}
