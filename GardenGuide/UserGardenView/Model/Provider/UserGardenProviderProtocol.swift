//
//  UserGardenProviderProtocol.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import Foundation
protocol UserGardenProviderProtocol {
    func getInformationAboutGardenPlants() async throws  -> [GardenPlant]
    func getInformationAboutFavouritePlants() async throws  -> [FavouritePlant]
    func getNewPlantByText(_ text: String) async throws -> [SuggestedPlantName]
    func getGardenPlantInformation(_ accessToken: String, name: String, watered: IrrigationInformation) async throws -> GardenPlant
}






