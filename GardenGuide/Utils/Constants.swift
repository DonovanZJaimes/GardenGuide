//
//  Constants.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 16/05/24.
//

import Foundation
struct Constants {
    static let apyKey = "uUAV0pEcCMm8if3lJcgcpok2DzWOtaW8owfKFyrCa4FnD9yQNN"
    static let ContentType = "application/json"
    static let irrigationInformation = IrrigationInformation(numberOfDays: -1, waterAmount: 0, percentage: 0, wasItWatered: false, nextIrrigation: Date.now)
    
}
