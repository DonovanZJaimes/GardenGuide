//
//  SimilarPlantsName.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 16/05/24.
//

import Foundation
struct SimilarPlantsName: Decodable {
    let entities: [SuggestedPlantName]

    enum CodingKeys: String, CodingKey {
        case entities
    }
}


