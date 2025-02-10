//
//  FavouritePlantCollectionViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 17/10/24.
//

import UIKit
import Kingfisher
//MARK: Protocol...
protocol FavouritePlantCollectionViewCellDelegate:AnyObject {
    func favouritePlantConfiguration(favouritePlant: FavouritePlant)
}

class FavouritePlantCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var plantNameLabel: UILabel!
    
    weak var delegate: FavouritePlantCollectionViewCellDelegate?
    var favouritePlant: FavouritePlant!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateImage(cornerRadius: 30)
    }
    
    //MARK: Methods to Cell
    func updateImage(cornerRadius: CGFloat) {
        //Configuration of the plant image design
        let borderColor: UIColor = .customDarkGreen
        plantImage.modifyCornerRadius(cornerRadius - 1, withColor: borderColor, andWidth: 0.3)
    }
    
    func updateCell(name: String, image: String, cornerRadius: CGFloat, favouritePlant: FavouritePlant){
        self.favouritePlant = favouritePlant
        //label
        plantNameLabel.text = favouritePlant.name
        //Image
        guard let urlImage = URL(string: favouritePlant.image) else { return }
        plantImage.kf.setImage(with: urlImage)
        updateImage(cornerRadius: cornerRadius)
    }
    
    @IBAction func plantConfiguration(_ sender: UIButton) {
        //send instructions to edit the selected plant
        delegate?.favouritePlantConfiguration(favouritePlant: self.favouritePlant)
    }
    

}
