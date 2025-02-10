//
//  GardenPlantCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 23/10/24.
//

import Foundation
struct GardenPlantCell: Hashable {
    let name: String
    var quantityOfWater: Int
    let image: String
    let irrigationStatus: IrrigationStatus
    var nextIrrigation: Date
    
}
