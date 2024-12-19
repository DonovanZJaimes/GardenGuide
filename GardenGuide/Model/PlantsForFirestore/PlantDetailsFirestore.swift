//
//  PlantDetailsFirestore.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 11/10/24.
//

import Foundation

struct PlantDetailsFirestore: Decodable {
    let commonNames: [String]?
    let url: String?
    let rank: String?
    let descriptionUrl: String?
    let descriptionValue: String?
    let synonyms: [String]?
    let imageUrl: String?
    let edibleParts: [String]?
    let wateringMax: Int?
    let wateringMin: Int?
    let propagationMethods: [String]?
}
