//
//  PlantDetails.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

struct PlantDetails: Decodable {
    let commonNames: [String]?
    let url: String
    let rank: String
    let description: Description
    let synonyms: [String]
    let image: DescriptionImage
    let edibleParts: [String]?
    let watering: Watered?

    enum CodingKeys: String, CodingKey {
        case commonNames = "common_names"
        case url
        case rank
        case description
        case synonyms
        case image
        case edibleParts = "edible_parts"
        case watering
    }
    
    struct Description: Decodable {
        let value: String
        let url: String

        enum CodingKeys: String, CodingKey {
            case value
            case url = "citation"
        }
    }
    struct DescriptionImage: Decodable {
        let url: String

        enum CodingKeys: String, CodingKey {
            case url = "value"
        }
    }
}


