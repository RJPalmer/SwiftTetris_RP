//
//  SceneDelegate.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate
{
    var window: UIWindow?

        func scene(_ scene: UIScene,
                   willConnectTo session: UISceneSession,
                   options connectionOptions: UIScene.ConnectionOptions) {

            guard let windowScene = (scene as? UIWindowScene) else { return }

            let window = UIWindow(windowScene: windowScene)
            // Set your initial view controller here
            window.rootViewController = MainMenuViewController() // Replace this
            self.window = window
            window.makeKeyAndVisible()
        }
}
