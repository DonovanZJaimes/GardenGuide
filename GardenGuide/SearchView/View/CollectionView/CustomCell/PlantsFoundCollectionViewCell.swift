//
//  PlantsFoundCollectionViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 07/05/24.
//

import UIKit
import Kingfisher

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
        guard let similarImages = plant.similarImages, let urlImage = URL(string: similarImages[0].url) else {
            plantImage.image = UIImage(systemName: "leaf.fill")
            plantImage.tintColor = .customGreen
            plantImage.contentMode = .scaleAspectFit
            return
        }
        plantImage.kf.setImage(with: urlImage)
        
    }
    
    @IBAction func addPlantToFavorites(_ sender: UIButton) {
        addPlantButton.isSelected.toggle()
    }
    
}
