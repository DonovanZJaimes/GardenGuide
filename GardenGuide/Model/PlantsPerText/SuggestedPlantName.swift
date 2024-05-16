//
//  SuggestedPlantName.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 16/05/24.
//

import Foundation

struct SuggestedPlantName: Decodable {
    let matchedIn: String
    let accessToken: String
    let plantName: String

    enum CodingKeys: String, CodingKey {
        case matchedIn = "matched_in"
        case accessToken = "access_token"
        case plantName = "entity_name"
    }
}
