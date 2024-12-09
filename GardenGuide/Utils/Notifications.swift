//
//  Notifications.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 24/06/24.
//

import Foundation
//MARK: Notification when a plant  is added or deleted in the garden
class Notifications {
    static let shared =  Notifications()
    //New notification
    static let plantsUpdateNotification = Notification.Name("Notifications.plantsUpdate")
    var newPlants = [String]() {
        didSet {
            NotificationCenter.default.post(name: Notifications.plantsUpdateNotification, object: nil)
        }
    }
}
