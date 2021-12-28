//
//  AppDelegate.swift
//  OpenGLESLearn
//
//  Created by lipengfei17 on 2021/12/28.
//

import UIKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let nav = UINavigationController.init(rootViewController: ViewController())
        window?.backgroundColor = .white
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }

    // MARK: UISceneSession Lifecycle

    

}

