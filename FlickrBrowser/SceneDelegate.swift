//
//  SceneDelegate.swift
//  FlickrBrowser
//
//  Created by Luke Van In on 2021/06/16.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = ListViewController()
        window?.makeKeyAndVisible()
    }

}

