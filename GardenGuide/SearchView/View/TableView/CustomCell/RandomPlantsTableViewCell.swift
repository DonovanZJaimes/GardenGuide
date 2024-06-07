//
//  RandomPlantsTableViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 16/05/24.
//

import UIKit

class RandomPlantsTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundUIView: UIView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //General view settings
        backgroundUIView.layer.cornerRadius = plantImageView.frame.width / 6//backgroundUIView.frame.height / 6
        plantImageView.layer.cornerRadius = plantImageView.frame.width / 6
    }
    
    
    func configureCell(plant: SuggestedPlant) {
        plantNameLabel.text = plant.name
        guard let similarImages = plant.similarImages, let urlImage = URL(string: similarImages[0].url) else {
            plantImageView.image = UIImage(systemName: "leaf.fill")
            plantImageView.tintColor = .customGreen
            return
        }
        plantImageView.kf.setImage(with: urlImage)
        
    }
    
}
