//
//  UILabel+Extension.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 17/01/25.
//

import Foundation
import UIKit
extension UILabel {
    public func underlineStyle(color: UIColor ) {
        guard let text = self.text else { return }
        // Create the underline attribute with color
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: color
        ]

        // Create the NSAttributedString with the attribute
        let attributedString = NSAttributedString(string: text, attributes: attributes)

        // Assign the NSAttributedString to the label
        attributedText = attributedString
    }
    
}
