//
//  SimilarImage.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

struct SimilarImage: Decodable {
    let id: String
    let url: String
    let similarity: Double
    let image: Data?

    enum CodingKeys: String, CodingKey {
        case id
        case url
        case similarity
        case image
    }
}
