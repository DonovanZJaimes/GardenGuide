//
//  SearchPlantForTableViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 28/05/24.
//

import UIKit

class SearchPlantForTableViewCell: UITableViewCell {

    @IBOutlet weak var entityNameLabel: UILabel!
    @IBOutlet weak var matchedNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(plant: SuggestedPlantName) {
        entityNameLabel.text = plant.plantName
        matchedNameLabel.text = plant.matchedIn
    }

    
    
}
