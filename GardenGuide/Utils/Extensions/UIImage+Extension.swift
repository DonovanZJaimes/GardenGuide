//
//  UIImage+Extension.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 01/06/24.
//

import Foundation
import UIKit

extension UIImageView {
    func modifyCornerRadius(_ radius: CGFloat, withColor color: UIColor? = nil , andWidth width: CGFloat? = nil) {
        layer.cornerRadius = radius
        if let color = color {
            layer.borderColor = color.cgColor
        }
        layer.borderWidth = (width == nil ? 0 : width)!
    }
}
