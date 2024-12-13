//
//  FirestoreDeleteData.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 04/10/24.
//

import Foundation
import FirebaseFirestore

struct FirestoreDeleteData {
    //Cloud Firestore
    static var shared =  FirestoreDeleteData()
    private let db = Firestore.firestore()
    private let CoUser = FirestoreUtilts.collectionUsers
    private let CoFavPlants = FirestoreUtilts.collectionFavouritePlants
    private let CoGarPlants = FirestoreUtilts.collectionGardenPlants
    private let CoSimImage = FirestoreUtilts.collectionSimilarImage
    private let CoIrrInfo = FirestoreUtilts.collectionIrrigationInformation
    private let CoDetInfo = FirestoreUtilts.collectionDetailsInformation
    
    //MARK: Methods for deleting user information in the Firestore Cloud
    
    //Delete a favourite plant
    func deletePlantOfFavouritesToCloud(_ name: String) async {
        do {
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoFavPlants).document(name).delete()
            print("delete plant of favourites on Firestore Cloud")
        } catch {
          print("Error delete plant of favourites: \(error)")
        }
    }
    
    //Delete a garden plant
    func deleteGardenPlantToCloud(_ plant: PlantForFirestore) async {
        do {
            //First: delete the plant's watering information
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(plant.name).collection(CoIrrInfo).document(CoIrrInfo).delete()
            //Second: delete the existing similar images
            if let similarImages = plant.similarImages {
                for index in 1 ... similarImages.count {
                    let documentSimilarImage = CoSimImage + String(index)
                    try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(plant.name).collection(CoSimImage).document(documentSimilarImage).delete()
                }
            }
            //Third: delete plant details information
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(plant.name).collection(CoDetInfo).document(CoDetInfo).delete()
            //Fourth: Delete the general plant information
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(plant.name).delete()
            print("delete garden plant on Firestore Cloud")
        } catch {
          print("Error delete garden plant: \(error)")
        }
    }
    
    
}
