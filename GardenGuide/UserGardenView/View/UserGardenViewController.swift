//
//  UserGardenViewController.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/05/24.
//

import UIKit

class UserGardenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Notifications.shared.newPlants.removeAll()
        tabBarController?.tabBar.items?[1].badgeValue = nil
    }

}
