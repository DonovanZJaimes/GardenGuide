//
//  IrrigationInformation.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 12/06/24.
//

import Foundation
 let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

struct IrrigationInformation: Decodable{
    var numberOfDays: Int16
    var waterAmount: Int16
    var percentage: Double
    var wasItWatered: Bool
    var nextIrrigation: Date
    
    // Inicializador personalizado
    init(numberOfDays: Int16, waterAmount: Int16, percentage: Double, wasItWatered: Bool, nextIrrigation: Date) {
        self.numberOfDays = numberOfDays
        self.waterAmount = waterAmount
        self.percentage = percentage
        self.wasItWatered = wasItWatered
        self.nextIrrigation = nextIrrigation
    }
        
    
    
    enum CodingKeys: String, CodingKey {
        case numberOfDays
        case waterAmount
        case percentage
        case wasItWatered
        case nextIrrigation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
           
        self.numberOfDays = try container.decode(Int16.self, forKey: .numberOfDays)
        self.waterAmount = try container.decode(Int16.self, forKey: .waterAmount)
        self.percentage = try container.decode(Double.self, forKey: .percentage)
        self.wasItWatered = try container.decode(Bool.self, forKey: .wasItWatered)
           
        // Aquí hacemos la conversión del string a Date
        let nextIrrigationString = try container.decode(String.self, forKey: .nextIrrigation)
        if let date = isoDateFormatter.date(from: nextIrrigationString) {
            self.nextIrrigation = date
        } else {
            throw DecodingError.dataCorruptedError(forKey: .nextIrrigation, in: container, debugDescription: "Formato de fecha inválido")
        }
    }
}
