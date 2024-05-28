//
//  SectionHeaderView.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 09/05/24.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    //MARK: Sub views
    //Design of the horizontal stackview that will contain the button and a title
    let stackViewHorizontal: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution  = .fill
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()
    
    //Design of the vertical stackview that will contain the previous stackview and a view
    let stackViewVertical: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution  = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    //separation line
    let lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = .lightGray
        return lineView
    }()

    //View design that will contain the image information
    let binaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .customOpaqueGreen
        return label
    }()
    
    //View design that will contain the information on the probability of the image
    let probabilityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .customOpaqueGreen
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 252), for: .horizontal)
        return label
    }()
    
       
    //MARK: Creating the frame that contains all the subviews above
    override init(frame: CGRect) {
        super.init(frame: frame)
        //Stackview and constraints are added
        stackViewVertical.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackViewVertical)
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: 1.5),
            stackViewVertical.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackViewVertical.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 360),
            stackViewVertical.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stackViewVertical.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        //Views are added to the stackviews
        stackViewHorizontal.addArrangedSubview(probabilityLabel)
        stackViewHorizontal.addArrangedSubview(binaryLabel)
        stackViewVertical.addArrangedSubview(lineView)
        stackViewVertical.addArrangedSubview(stackViewHorizontal)     
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
