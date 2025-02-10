//
//  IrrigationStatus.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 21/10/24.
//

import Foundation
import UIKit


enum IrrigationStatus {
    case watered
    case wet
    case dry
}

extension IrrigationStatus{
    var color: UIColor  {
        switch self {
        case .watered:
            let color: UIColor = .customGreen
            return color
        case .wet:
            let color: UIColor = .customYellow
            return color
        case .dry:
            let color = UIColor(named: "ErrorRed")!
            return color
        }
    }
}

extension IrrigationStatus{
    var image: UIImage  {
        switch self {
        case .watered:
            let image = UIImage(systemName: "drop.fill")!
            return image
        case .wet:
            let image = UIImage(named: "drop.halffull")!
            return image
        case .dry:
            let image = UIImage(systemName: "drop")!
            return image
        }
    }
}


