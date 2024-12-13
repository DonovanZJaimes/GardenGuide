//
//  FirestoreEditData.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 03/10/24.
//

import Foundation
import FirebaseFirestore

struct FirestoreEditData {
    //Cloud Firestore
    static var shared =  FirestoreEditData()
    private let db = Firestore.firestore()
    private let CoUser = FirestoreUtilts.collectionUsers
    private let CoFavPlants = FirestoreUtilts.collectionFavouritePlants
    private let CoGarPlants = FirestoreUtilts.collectionGardenPlants
    private let CoSimImage = FirestoreUtilts.collectionSimilarImage
    private let CoIrrInfo = FirestoreUtilts.collectionIrrigationInformation
    
    //MARK: Methods for editing user information in the Firestore Cloud
    
    //Modify the user provider
    func editCloudUserProvider(with email: String, andProvider provider: String) async {
        do {
            try await db.collection(CoUser).document(email).updateData([
                "provider": provider
            ])
            print("edit new provider on Firestore Cloud")
        } catch {
          print("Error edit new provider: \(error)")
        }
    }
    
    //Change a plant's watering information
    func editIrrigationInformationOfGardenPlant(name: String, watered: IrrigationInformation) async {
        do {
            try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).document(name).collection(CoIrrInfo).document(CoIrrInfo).updateData([
                "numberOfDays" : watered.numberOfDays,
                "waterAmount" : watered.waterAmount,
                "percentage" : watered.percentage,
                "wasItWatered" : watered.wasItWatered,
                "nextIrrigation" : watered.nextIrrigation
            ])
            
            print("edit new Irrigation Information on Firestore Cloud")
        } catch {
          print("Error edit new Irrigation Information: \(error)")
        }
    }
    
    
    
    
}
