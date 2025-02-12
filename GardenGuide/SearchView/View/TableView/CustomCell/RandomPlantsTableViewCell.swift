//
//  RandomPlantsTableViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 16/05/24.
//

import UIKit

class RandomPlantsTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var backgroundUIView: UIView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //General view settings
        backgroundUIView.layer.cornerRadius = plantImageView.frame.width / 6
        plantImageView.layer.cornerRadius = plantImageView.frame.width / 6
    }
    
    //MARK: Methods to Cell
    func configureCell(plant: SuggestedPlant) {
        //label
        plantNameLabel.text = plant.name
        let imageURL = plant.similarImages?.first?.url ?? plant.details.image?.url
        //image
        guard let imageURL = imageURL else {
            plantImageView.image = UIImage(systemName: "leaf.fill")
            plantImageView.tintColor = .customGreen
            return
        }
        let urlImage = URL(string: imageURL)
        plantImageView.kf.setImage(with: urlImage)
        
    }
    
}
