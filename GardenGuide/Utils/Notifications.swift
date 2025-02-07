//
//  Notifications.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 24/06/24.
//

import Foundation
import FirebaseAuth
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
    
    //New notification
    static let userAnonymouslyNotification = Notification.Name("Notifications.userAnonymously")
    var user: User! {
        didSet {
            NotificationCenter.default.post(name: Notifications.userAnonymouslyNotification, object: nil)
        }
    }
    
    //New notification
    static let sendPlantNotification = Notification.Name("Notifications.sendPlant")
    var newFavouritePlant: Bool = false {
        didSet {
            NotificationCenter.default.post(name: Notifications.sendPlantNotification, object: nil)
        }
    }
    
    
}
