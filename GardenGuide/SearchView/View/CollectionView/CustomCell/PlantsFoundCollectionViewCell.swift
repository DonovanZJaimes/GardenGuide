//
//  PlantsFoundCollectionViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 07/05/24.
//

import UIKit

class PlantsFoundCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var addPlantButton: UIButton!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var namePlantLabel: UILabel!
    @IBOutlet weak var probabilityLabel: UILabel!
    @IBOutlet weak var backgroundInfoView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //General view settings
        backgroundInfoView.layer.cornerRadius = backgroundInfoView.frame.height / 4
        plantImage.layer.cornerRadius = plantImage.frame.width / 10
    }
    
    
    func configureCell(plant: SuggestedPlant) {
        namePlantLabel.text = plant.name
        probabilityLabel.text = "\(plant.probability)"
        
    }
    
    @IBAction func addPlantToFavorites(_ sender: UIButton) {
        addPlantButton.isSelected.toggle()
    }
    
}
