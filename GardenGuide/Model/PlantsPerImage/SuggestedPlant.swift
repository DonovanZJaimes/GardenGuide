//
//  SuggestedPlant.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation


struct SuggestedPlant: Decodable {
    let id: String
    let name: String
    let probability: Double
    let similarImages: [SimilarImage]?
    let details: PlantDetails

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case probability
        case similarImages = "similar_images"
        case details
    }
}


