//
//  PlantForFirestore.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/10/24.
//

import Foundation
struct PlantForFirestore: Decodable {
    let name: String
    var isAdded: Bool 
    let similarImages: [SimilarImage]?
    let details: PlantDetailsFirestore
    let watered: IrrigationInformation
    
}

struct PlantsForFirestore: Decodable {
    let elements: [PlantForFirestore]
}
