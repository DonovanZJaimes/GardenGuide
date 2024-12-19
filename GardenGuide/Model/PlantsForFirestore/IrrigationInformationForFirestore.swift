//
//  IrrigationInformationForFirestore.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 25/10/24.
//

import Foundation

struct IrrigationInformationForFirestore: Decodable{
    var numberOfDays: Int16
    var waterAmount: Int16
    var percentage: Double
    var wasItWatered: Bool
    var nextIrrigation: Date
}
