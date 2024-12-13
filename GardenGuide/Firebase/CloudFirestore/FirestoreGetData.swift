//
//  FirestoreGetData.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 04/10/24.
//

import Foundation
import FirebaseFirestore

struct FirestoreGetData {
    //Cloud Firestore
    static var shared =  FirestoreGetData()
    private let db = Firestore.firestore()
    private let CoUser = FirestoreUtilts.collectionUsers
    private let CoFavPlants = FirestoreUtilts.collectionFavouritePlants
    private let CoGarPlants = FirestoreUtilts.collectionGardenPlants
    private let CoSimImage = FirestoreUtilts.collectionSimilarImage
    private let CoIrrInfo = FirestoreUtilts.collectionIrrigationInformation
    private let CoDetInfo = FirestoreUtilts.collectionDetailsInformation
    
    //MARK: Methods for get user information in the Firestore Cloud
    
    //Get all the favorite plants
    func getPlantsOfFavouritesToCloud() async throws -> [FavouritePlantInFirestore] {
        var favouritePlantsInFirestore = [FavouritePlantInFirestore]()
        do {
            //get the data of all favorite plants
            let collectionFavouritePlants = try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoFavPlants).getDocuments()
            do {
                //The plant data becomes a model
                for plant in collectionFavouritePlants.documents {
                    let plant = try plant.data(as: FavouritePlantInFirestore.self)
                    favouritePlantsInFirestore.append(plant)
                }
            } catch {
                print("Error docoding plants: \(error)")
            }
            print("get plants on Firestore Cloud")
            
        } catch {
            print("Error get plants: \(error)")
        }
        return favouritePlantsInFirestore
    }
    
    //Get all the garden plants
    func getGardenPlantsToCloud() async throws  -> [PlantForFirestore] {
        var plantsForFirestore = [PlantForFirestore]()
        do {
            //get the data of all garden plants
            let collectionGardenPlants = try await db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(CoGarPlants).getDocuments()
            for plant in collectionGardenPlants.documents {
                //Get all model information to plantFoFirestore model
                if let name = plant.get("name") {
                    let (details, irrigationInformation, similarImages) = await getGardenPlantInfoToCloud(name: name as! String)
                    let plantForFirestore = PlantForFirestore(name: name as! String, isAdded: true, similarImages: similarImages, details: details!, watered: irrigationInformation!)
                    plantsForFirestore.append(plantForFirestore)
                }
            }
            print("get plants on Firestore Cloud")
        } catch {
            print("Error get plants: \(error)")
        }
        return plantsForFirestore
    }
    
    //Get the various general information about garden plant
    private func getGardenPlantInfoToCloud(name: String) async -> (PlantDetailsFirestore?, IrrigationInformation?, [SimilarImage]?) {
        let collectionName = CoGarPlants + "/" + name + "/"
        //variables to make asynchronous calls
        async let collectionGardenPlantDetails =  db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(collectionName + CoDetInfo).getDocuments()
        async let collectionGardenPlantIrrigationInformation = db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(collectionName + CoIrrInfo).getDocuments()
        async let collectionGardenPlantSimilarImages = db.collection(CoUser).document(FirestoreUtilts.userEmail).collection(collectionName + CoSimImage).getDocuments()
        do {
            //To do the asynchronous calls to get information of the plant
            let (plantDetails, plantIrrigationInformation, CoSimilarImages) = await (try collectionGardenPlantDetails, try collectionGardenPlantIrrigationInformation, try collectionGardenPlantSimilarImages)
            //Become the data to a model
            let details = try plantDetails.documents.first?.data(as: PlantDetailsFirestore.self)
            let watered = try plantIrrigationInformation.documents.first?.data(as: IrrigationInformationForFirestore.self)
            let irrigationInformation = IrrigationInformation(numberOfDays: watered!.numberOfDays, waterAmount: watered!.waterAmount, percentage: watered!.percentage, wasItWatered: watered!.wasItWatered, nextIrrigation: watered!.nextIrrigation)
            var similarImages = [SimilarImage]()
            for document in CoSimilarImages.documents {
                let similarImage = try document.data(as: SimilarImage.self)
                similarImages.append(similarImage)
            }
            return (details, irrigationInformation, similarImages)
        } catch {
            print("Error get plant details: \(error)")
            return (nil, nil, nil)
        }
    }
    
    
}
