//
//  Notifications.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 24/06/24.
//

import Foundation
class Notifications {
    static let shared =  Notifications()
    //New notification
    static let plantsUpdateNotification = Notification.Name("Notifications.plantsUpdate")
    var newPlants = [PlantInformation]() {
        didSet {
            NotificationCenter.default.post(name: Notifications.plantsUpdateNotification, object: nil)
        }
    }
}
