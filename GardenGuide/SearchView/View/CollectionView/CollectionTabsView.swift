//
//  CollectionTabsView.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 07/05/24.
//

import Foundation
import UIKit
protocol CollectionTabsViewDelegate: AnyObject {
    func didSelectPlant(index: Int)
}

class CollectionTabsView: UIView {
    private lazy var collectionView: UICollectionView = {
        //Create Collection
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionHeadersPinToVisibleBounds = true
        let collection = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        //Configure Collection
        collection.delegate = self
        collection.dataSource = self
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.clipsToBounds = false
        collection.backgroundColor = .customBackgroundColor
        
        //Register Cell
        collection.register(UINib(nibName: "\(PlantsFoundCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "\(PlantsFoundCollectionViewCell.self)")
        //Register Header
        collection.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(SectionHeaderView.self)")
        
        return collection
    }()
    
    //inits
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configCollectionView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //Global variables
    private var plants : PlantsByImageSearch!
    weak private var delegate: CollectionTabsViewDelegate?
    
    
    //MARK: Functions
    //Set constraints
    private func configCollectionView(){
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: 46),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    //start content from CollectionViewCell
    func buildView(delegate: CollectionTabsViewDelegate, plants: PlantsByImageSearch){
        self.delegate = delegate
        self.plants = plants
        collectionView.reloadData()
    }
    
 
}
//MARK: Extension from DataSource and Delegate
extension CollectionTabsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let _ = plants else {
            return 0
        }
        return self.plants.suggestedPlants.count
    }
    
    // Cell content
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PlantsFoundCollectionViewCell.self)", for: indexPath) as? PlantsFoundCollectionViewCell else {
            return UICollectionViewCell()
        }
        let suggestedPlant = plants.suggestedPlants[indexPath.row]
        cell.configureCell(plant: suggestedPlant)
        
        return cell
    }
    
    //Supplementary view for header
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            //Set header info
            var binaryText = ""
            var probablyText = "..."
            if let _ = plants  {
                binaryText =  plants.isPlant.binary == true ? " that the image is a plant" : "that the image is not a plant"
                probablyText =  "\(plants.isPlant.probability) " + "% probability"
            }
            //Configure header
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(SectionHeaderView.self)", for: indexPath) as! SectionHeaderView
            
            headerView.binaryLabel.text = binaryText
            headerView.probabilityLabel.text = probablyText
            
            return headerView
            
        default:
            return UICollectionReusableView()
        }
    }
    
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
       return CGSize(width: 5, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectPlant(index: indexPath.row)
    }

}

//MARK: Extension from DelegateFlowLayout
extension CollectionTabsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 224)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
   
}

