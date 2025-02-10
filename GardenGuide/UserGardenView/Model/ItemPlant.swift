//
//  ItemPlant.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 28/10/24.
//

import Foundation

enum ItemPlant: Hashable {
    case favouritePlant(FavouritePlant)
    case gardenPlant(GardenPlantCell)
    
    //Property to create a favourite plant
    var favouritePlant: FavouritePlant?{
        if case .favouritePlant(let favouritePlant) = self {
            return favouritePlant
        } else {
            return nil
        }
    }
    
    //Property to create a garden plant
    var gardenPlant: GardenPlantCell? {
        if case.gardenPlant(let gardenPlant) = self {
            return gardenPlant
        } else {
            return nil
        }
    }
    
    // Empty properties that will help us to record the information of each section of the ‘UserGardenView’
    static var favouritePlants: [ItemPlant] = []
    static var gardenPlants: [[ItemPlant]] = [[]]
}
