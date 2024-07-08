//
//  PlantInformation.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/06/24.
//

import Foundation
//Information model for PlantDetailsViewController
struct PlantInformation: Decodable {
    let name: String
    var isAdded: Bool = false
    let similarImages: [SimilarImage]?
    let details: PlantDetails
}
