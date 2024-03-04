//
//  SceneDelegate.swift
//  InstagramClone
//
//  Created by Lova Krishna on 18/04/20.
//  Copyright © 2020 Lova Krishna. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import Photos

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        FirebaseApp.configure()  // Ensure Firebase is configured only once and here is usually a good spot.
        setupUI()
        showRootViewController()
    }
    
    // MARK: - UI Setup
        fileprivate func setupUI() {
            setupNavBar()
            setupTabbar()
        }
        
        // MARK: - Root View Controller Management
        func showRootViewController() {
            let initialVC = determineInitialViewController()
            window?.switchRootViewController(initialVC, animated: true)
            window?.makeKeyAndVisible()
        }
        
        fileprivate func determineInitialViewController() -> UIViewController {
            if Auth.auth().currentUser != nil {
                return TabBarController()
            } else {
                return UINavigationController(rootViewController: SignInViewController()) 
            }
        }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    
    fileprivate func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "#00BFFF") // Your custom color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Title color
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white] // Large title color if used
        
        // Apply appearance to iOS 15 and later versions
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance // For iPhone small navigation bar in landscape.
        } else {
            // Fallback for iOS 14 and below
            UINavigationBar.appearance().barTintColor = UIColor(hex: "#00BFFF")
            UINavigationBar.appearance().tintColor = UIColor.white
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
            UINavigationBar.appearance().isTranslucent = false
        }
    }
    
    
    fileprivate func setupTabbar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hex: "#00BFFF") // Your custom color
        
        // Set the color for the selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Set the color for the unselected state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.black
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        // Apply appearance to iOS 15 and later versions
        if #available(iOS 15.0, *) {
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Fallback for iOS 14 and below
            UITabBar.appearance().barTintColor = UIColor(hex: "#00BFFF")
            UITabBar.appearance().tintColor = UIColor.white
            UITabBar.appearance().unselectedItemTintColor = UIColor.black
            UITabBar.appearance().isTranslucent = false
        }
    }
}

