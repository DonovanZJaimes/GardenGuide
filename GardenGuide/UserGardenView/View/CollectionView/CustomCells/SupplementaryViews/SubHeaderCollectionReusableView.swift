//
//  SubHeaderCollectionReusableView.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import UIKit

class SubHeaderCollectionReusableView: UICollectionReusableView {
    //View identifier
    static let reuseIdentifier = "SubSectionHeaderView"
    
    //MARK: Sub  views
    //Design of the horizontal stackview that will contain a title and other views.
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution  = .fill
        stackView.alignment = .center
        return stackView
    }()

    //Design of a view containing the title of the date of each irrigation.
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = .customOpaqueGreen
        return label
    }()
    

    //MARK: Creation of the framework containing all the above sub-views.
    override init(frame: CGRect) {
        super.init(frame: frame)
        //  The stackview is added
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        //Title label is added
        stackView.addArrangedSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Update Title
    func setTitle (_ title: String){
        label.text = title
    }
}


