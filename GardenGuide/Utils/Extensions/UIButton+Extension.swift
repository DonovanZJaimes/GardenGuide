//
//  UIButton+Extension.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 12/04/24.
//

import Foundation
import UIKit

extension UIButton {
    func modifyCornerRadius(_ radius: CGFloat, withColor color: UIColor? = nil , andWidth width: CGFloat? = nil) {
        layer.cornerRadius = radius
        if let color = color {
            layer.borderColor = color.cgColor
        }
        layer.borderWidth = (width == nil ? 0 : width)!
    }
}
