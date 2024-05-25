//
//  PlantsByImageSearch.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/05/24.
//

import Foundation

struct PlantsByImageSearch: Decodable {
    let isPlant: IsPlant
    let suggestedPlants: [SuggestedPlant]
    
}
