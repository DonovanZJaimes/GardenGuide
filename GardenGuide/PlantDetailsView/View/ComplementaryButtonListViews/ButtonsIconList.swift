//
//  ButtonsIconList.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 04/06/24.
//

import Foundation
import UIKit

protocol ButtonIconListProtocol: AnyObject{
    func didSelectOption(tag : Int)
}

class ButtonIconList: UIView {
    //MARK: Variables
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return scrollView
    }()
    
    private let optionsView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.backgroundColor = .clear
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //MARK: Required Methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var butonIconList = [DetailsButtonIcon]()
    weak var delegate : ButtonIconListProtocol?
    
    
    private func buildButton(buttonObject: DetailsButtonIcon, tag: Int) ->  UIView {
        let button = UIButton(type: .custom)
        button.tag = tag
        button.setImage(UIImage(systemName: buttonObject.icon.rawValue), for: .normal)
        button.addTarget(self, action: #selector(didSelectOption(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .customGreen
        
        let titleLabel = UILabel()
        titleLabel.text = buttonObject.title
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        let stackButtons: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
                //.fillProportionally
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(button)
            stackView.addArrangedSubview(titleLabel)
            return stackView
        }()
        NSLayoutConstraint.activate([
            stackButtons.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        return stackButtons
    }
    
    func buildView() {
        _ = optionsView.arrangedSubviews.map({$0.removeFromSuperview()})
        for (i, button) in butonIconList.enumerated() {
            let buttonView = buildButton(buttonObject: button, tag: i)
            optionsView.addArrangedSubview(buttonView)
        }
        scrollView.addSubview(optionsView)
        
        NSLayoutConstraint.activate([
            optionsView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            optionsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            optionsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ])
    }
    
    
    @objc func didSelectOption(_ sender: UIButton) {
        delegate?.didSelectOption(tag: sender.tag)
    }
    
}
