//
//  SimilarPlants.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

struct SimilarPlants: Decodable {
    let accessToken : String
    let result: ResultOfSimilarPlants
    let status: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case result
        case status
    }
}
