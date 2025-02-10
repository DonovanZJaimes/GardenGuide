//
//  FavouritePlant.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import Foundation
struct FavouritePlants: Codable, Hashable {
    let elements: [FavouritePlant]
}

struct FavouritePlant: Codable, Hashable {
    let name: String
    let image: String
    var min: Int
    var max: Int
}

