//
//  SectionTitleView.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 17/05/24.
//

import UIKit

class SectionTitleView: UITableViewHeaderFooterView {

    //MARK: Sub views
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
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .customOpaqueGreen
        return label
    }()
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        //Stackview and constraints are added
        stackViewVertical.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackViewVertical)
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: 1.5),
            stackViewVertical.topAnchor.constraint(equalTo: topAnchor, constant: -15),
            stackViewVertical.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            stackViewVertical.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stackViewVertical.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
        ])
        stackViewVertical.backgroundColor = .customBackgroundColor
        stackViewVertical.addArrangedSubview(lineView)
        stackViewVertical.addArrangedSubview(titleLabel) 
    }
    
   

}
