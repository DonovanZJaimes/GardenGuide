//
//  LineCollectionReusableView.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import UIKit

//Creation of a view that will serve as a separator in the categories of the collectionView.
class LineCollectionReusableView: UICollectionReusableView {
    //view identifier
    static let reuseIdentifier = "LineView"
    
    //Creation of the view frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //  method to change the colour of the dividing line
    func setColor(_ color: UIColor) {
        backgroundColor = color
    }
}
