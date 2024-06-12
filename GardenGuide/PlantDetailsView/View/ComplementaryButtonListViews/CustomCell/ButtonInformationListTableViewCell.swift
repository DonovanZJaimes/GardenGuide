//
//  ButtonInformationListTableViewCell.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 06/06/24.
//

import UIKit

class ButtonInformationListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundNameView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundNameView.layer.cornerRadius = backgroundNameView.frame.height / 4
    }

    func configCell(_ name: String) {
        nameLabel.text = name
    }
    
    
}
