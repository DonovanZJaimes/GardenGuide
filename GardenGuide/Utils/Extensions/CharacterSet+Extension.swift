//
//  CharacterSet+Extension.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 17/04/24.
//

import Foundation
extension CharacterSet {
    
    func getCharacters() -> [String] {
        let characterSet = self as NSCharacterSet
        var characters: [String] = []
        for plane:UInt8 in 0..<17 {
            if characterSet.hasMemberInPlane(plane) {
                let planeStart = UInt32(plane) << 16
                let nextPlaneStart = (UInt32(plane) + 1) << 16
                for char: UTF32Char in planeStart..<nextPlaneStart {
                    if characterSet.longCharacterIsMember(char) {
                        if let unicodeCharacter = UnicodeScalar(char) {
                            characters.append(String(unicodeCharacter))
                        }
                    }
                }
            }
        }
        return characters
    }
    
}
