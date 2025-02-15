//
//  NotificationsTests.swift
//  GardenGuideUnitTests
//
//  Created by Donovan Z. Jaimes on 14/02/25.
//

import XCTest
@testable import GardenGuide

final class NotificationsTests: XCTestCase {

    override func setUpWithError() throws {
        Notifications.shared.newPlants.removeAll()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

//Notifications.shared.newPlants.append("new plant")
/**
 
 if Notifications.shared.newPlants.count != 0 {
     Notifications.shared.newPlants.removeLast()
 }
 
 
 Notifications.shared.newPlants.removeAll()
 
 
 
 @objc func updateItemUserGardenView() {
     /*if Notifications.shared.newPlants.count != nil {
         //tabBarItemUserGardenView.badgeValue = (value == 0) ? nil : String(value)
     }*/
     let value = Notifications.shared.newPlants.count
     tabBarItemUserGardenView.badgeValue = (value == 0) ? nil : String(value)
 }
 
 
 func configItemUserGardenView(){
     NotificationCenter.default.addObserver(self, selector: #selector(updateItemUserGardenView), name: Notifications.plantsUpdateNotification, object: nil)
     
     tabBarItemUserGardenView = (window?.rootViewController as? UITabBarController)?.viewControllers?[1].tabBarItem
     
 }
 */
