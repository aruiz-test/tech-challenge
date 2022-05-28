//
//  AppDelegate.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 28/5/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)

        if let window = self.window {
            let navigationController = UINavigationController(rootViewController: ViewController())
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
        
        return true
    }

}

