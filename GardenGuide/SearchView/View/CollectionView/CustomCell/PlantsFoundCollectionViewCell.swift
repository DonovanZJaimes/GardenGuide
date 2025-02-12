//
//  PlantsFoundCollectionViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 07/05/24.
//

import UIKit
import Kingfisher

//MARK: Delegate for GardenGuide
protocol PlantsFoundCollectionViewCellDelegate: AnyObject {
    func addPlantToFavorites(name: String, image: String, isSelected: Bool, sender: UIButton, plant: FavouritePlant) -> Bool
}

class PlantsFoundCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var addPlantButton: UIButton!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var namePlantLabel: UILabel!
    @IBOutlet weak var probabilityLabel: UILabel!
    @IBOutlet weak var backgroundInfoView: UIView!
    
    //MARK: general variables
    weak var delegate: PlantsFoundCollectionViewCellDelegate?
    private var image: String = ""
    private var favouritePlant: FavouritePlant!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //General view settings
        backgroundInfoView.layer.cornerRadius = backgroundInfoView.frame.height / 4
        plantImage.layer.cornerRadius = plantImage.frame.width / 10
    }
    
    //MARK: Methods to Cell
    
    func configureCell(plant: SuggestedPlant) {
        //labels
        namePlantLabel.text = plant.name
        probabilityLabel.text = "\(plant.probability)"
        addPlantButton.isSelected = CoreDataUtils.shared.plantIsInFavorites(plant) //Check if the plant is in favourites
        //image
        guard let similarImages = plant.similarImages, let urlImage = URL(string: similarImages[0].url) else {
            plantImage.image = UIImage(systemName: "leaf.fill")
            plantImage.tintColor = .customGreen
            plantImage.contentMode = .scaleAspectFit
            return
        }
        plantImage.kf.setImage(with: urlImage)
        self.image = plant.details.image?.url ?? Constants.imagePlant
        
        self.favouritePlant = FavouritePlant(name: namePlantLabel.text!, image: image, min: plant.details.watering?.min ?? 1, max: plant.details.watering?.max ?? 1)
    }
    
    //MARK: cell Actions
    @IBAction func addPlantToFavorites(_ sender: UIButton) {
        //Check to see if the plant wiil be saved or deleted by CoreData
        let isSelected = delegate?.addPlantToFavorites(name: namePlantLabel.text!, image: image, isSelected: !addPlantButton.isSelected, sender: sender, plant: favouritePlant)
        addPlantButton.isSelected = isSelected!
    }
    
}
