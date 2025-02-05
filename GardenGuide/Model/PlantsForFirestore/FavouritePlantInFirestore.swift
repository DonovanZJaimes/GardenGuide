//
//  FavouritePlantInFirestore.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 05/10/24.
//

import Foundation
struct FavouritePlantInFirestore: Decodable {
    let name: String
    let image: String
    var min: Int
    var max: Int
}
