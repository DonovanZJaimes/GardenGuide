//
//  SceneDelegate.swift
//  GardenGuide
//
//  Created by Donovan Z. Jaimes on 08/04/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var tabBarItemUserGardenView: UITabBarItem!
    
    @objc func updateItemUserGardenView() {
        let value = Notifications.shared.newPlants.count
        tabBarItemUserGardenView.badgeValue = (value == 0) ? nil : String(value)
    }
    
    
    func configItemUserGardenView(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateItemUserGardenView), name: Notifications.plantsUpdateNotification, object: nil)
        
        tabBarItemUserGardenView = (window?.rootViewController as? UITabBarController)?.viewControllers?[1].tabBarItem
        
    }


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let defaults = UserDefaults.standard
            if let email = defaults.value(forKey: "email") as? String, let provider = defaults.value(forKey: "provider") as? String {
                
                //MARK: Go to Storyboard with authentication
                let mainStoryboard = UIStoryboard(name: "GardenGuide", bundle: .main)
                if let gardenGuideTabBarController = mainStoryboard.instantiateViewController(withIdentifier: "GardenGuideTBC") as? UITabBarController, let gardenGuideViewController  = mainStoryboard.instantiateViewController(withIdentifier: "GardenGuideVC") as? GardenGuideViewController {
                    gardenGuideViewController.email = email
                    gardenGuideViewController.provider = ProviderType.init(rawValue: provider)!
                    //gardenGuideTabBarController.viewControllers?[0] = gardenGuideViewController
                    let navigationController = UINavigationController (rootViewController:  gardenGuideViewController)
                    gardenGuideTabBarController.viewControllers?[0] = navigationController
                    window.rootViewController = gardenGuideTabBarController
                    self.window = window
                    window.makeKeyAndVisible()
                }
            } else {
                
                //MARK: Go to Storyboard without authentication
                let authStoryboard = UIStoryboard(name: "AuthMain", bundle: .main)
                if let authMainViewController = authStoryboard.instantiateViewController(withIdentifier: "AuthMainVC") as? AuthMainViewController {
                    window.rootViewController = authMainViewController
                    self.window = window
                    window.makeKeyAndVisible()
                }
            }
        }
        
        configItemUserGardenView()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

