//
//  SettingsProvider.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/01/25.
//

import Foundation
class SettingsProvider {
    let defaults = UserDefaults.standard
    //get user's email and provider
    func getUserProvider() -> (ProviderType, String) {
        var userProviderType: ProviderType!
        var userEmail: String!
        if let email = defaults.value(forKey: "email") as? String, let provider = defaults.value(forKey: "provider") as? String, let providerType = ProviderType.init(rawValue: provider) {
            userProviderType = providerType
            userEmail = email
        }
        return (userProviderType, userEmail)
    }
}
