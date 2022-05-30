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
        
        // Create the window, the root view controller and start the app
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let window = self.window {
            window.rootViewController = createRootViewController()
            window.makeKeyAndVisible()
        }
        
        // Setup URL cache settings
        setupURLCache()
        
        return true
    }
    
    private func createRootViewController() -> UIViewController {
        let firstViewController = MoviesListViewController()
        let navigationController = UINavigationController(rootViewController: firstViewController)
        return navigationController
    }

    private func setupURLCache() {
        URLSession.shared.configuration.requestCachePolicy = .returnCacheDataElseLoad
        URLCache.shared = {
            let cacheDirectory = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String).appendingFormat("/\(Bundle.main.bundleIdentifier ?? "cache")/" )

            return URLCache(memoryCapacity: 0,
                            diskCapacity: 100 * 1024 * 1024,
                            diskPath: cacheDirectory)
        }()
    }
    
}

