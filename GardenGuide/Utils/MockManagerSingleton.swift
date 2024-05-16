//
//  MockManagerSingleton.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 16/05/24.
//

import Foundation

struct MockManagerSingleton {
    static var shared =  MockManagerSingleton()
    var runAppWithMock: Bool = true
}
