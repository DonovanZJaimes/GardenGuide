//
//  GardenPlant.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import Foundation

struct GardenPlant: Decodable {
    let plantInformation: PlantInformation
    var watered: IrrigationInformation
}
