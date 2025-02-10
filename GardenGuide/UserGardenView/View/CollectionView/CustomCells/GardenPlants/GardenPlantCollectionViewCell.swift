//
//  GardenPlantCollectionViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 17/10/24.
//

import UIKit
import Kingfisher
//MARK: Protocol to Delegate
protocol GardenPlantCollectionViewCellDelegate:AnyObject {
    func gardenPlantConfiguration(name: String, sender: UIButton, completion: @escaping (Bool) -> Void)
    func updateColectionView()
    func editPlantWatering(name: String)
    func deleteGardenPlant(name: String, sender: UIButton)
}

class GardenPlantCollectionViewCell: UICollectionViewCell {

    //MARK: Outlets
    @IBOutlet weak var plantImage: UIImageView!
    @IBOutlet weak var namePlantLabel: UILabel!
    @IBOutlet weak var quantityOfWaterLabel: UILabel!
    @IBOutlet weak var dropImage: UIImageView!
    @IBOutlet weak var backgroundUIView: UIView!
    @IBOutlet weak var irrigationButtonWidthConstraint: NSLayoutConstraint!
    
    //MARK: general variables
    weak var delegate: GardenPlantCollectionViewCellDelegate?
    var isEliminationMode: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    //MARK: Methods to Cell
    
    //configurate the information on the views
    func updateCell(plant: GardenPlantCell, isInEliminationMode: Bool){
        isEliminationMode = isInEliminationMode
        //labels
        namePlantLabel.text = plant.name
        quantityOfWaterLabel.text = String(plant.quantityOfWater) + " ml"
        quantityOfWaterLabel.underlineStyle(color: quantityOfWaterLabel.textColor)
        //button
        editIrrigationButtonWidth()
        //images
        updateDropImage(irrigationStatus: plant.irrigationStatus)
        guard let urlImage = URL(string: plant.image) else { return }
        plantImage.kf.setImage(with: urlImage)
        //corner radoius
        backgroundUIView.layer.cornerRadius = plantImage.frame.width / 6//backgroundUIView.frame.height / 6
        plantImage.layer.cornerRadius = plantImage.frame.width / 6
    }
    
    //determinate  dropImage settings based on IrrigationStatus model
    func updateDropImage(irrigationStatus: IrrigationStatus){
        switch isEliminationMode {
        case true:
            dropImage.image = .remove
            dropImage.tintColor = .red
        case false:
            dropImage.tintColor = irrigationStatus.color
            dropImage.image = irrigationStatus.image
        }
    }
    
    
    private func editIrrigationButtonWidth(){
        //determine the width of the button according to the quantityOfWaterLabel text
        let label = UILabel()
        label.text = quantityOfWaterLabel.text
        label.font = .systemFont(ofSize: 17)
        let labelWidth = label.intrinsicContentSize.width
        let buttonWidth = CGFloat(36) + labelWidth
        
        irrigationButtonWidthConstraint.constant = buttonWidth
    }
    
    
    //MARK: ViewController Actions
    
    
    @IBAction func selectDropImage(_ sender: UIButton) {
        //check if the button was selected to delete the plant or was selected to water the plant
        switch isEliminationMode {
        case true:
            //delete
            delegate?.deleteGardenPlant(name: namePlantLabel.text!, sender: sender)
        case false:
            // watered
            delegate?.gardenPlantConfiguration(name: namePlantLabel.text!, sender: sender, completion: { [unowned self] isThePlantWatered in
                guard isThePlantWatered else {return}
                //update the views in case the plant has been irrigated
                dropImage.tintColor = IrrigationStatus.watered.color
                dropImage.image = IrrigationStatus.watered.image
                delegate?.updateColectionView()
            })
        }
    }
    
    @IBAction func modifyPlantIrrigationButton(_ sender: UIButton) {
        //send instructions to edit the selected plant
        delegate?.editPlantWatering(name: namePlantLabel.text!)
    }
    
    
}
