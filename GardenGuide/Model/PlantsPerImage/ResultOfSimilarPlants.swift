//
//  ResultOfSimilarPlants.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

struct ResultOfSimilarPlants: Decodable {
    let classification: Classification
    let isPlant: IsPlant

    enum CodingKeys: String, CodingKey {
        case classification
        case isPlant = "is_plant"
    }
    
    struct Classification: Decodable {
        let suggestedPlants: [SuggestedPlant]
        
        enum CodingKeys: String, CodingKey {
            case suggestedPlants = "suggestions"
        }
    }
    
}


