//
//  SceneDelegate.swift
//  AutoCatalog
//
//  Created by Uzver on 15.09.2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

   var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}
