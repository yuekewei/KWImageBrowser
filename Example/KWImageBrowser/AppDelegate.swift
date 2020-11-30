//
//  AppDelegate.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/12.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow.init(frame: UIScreen.main.bounds);
        window?.backgroundColor = .white;
        window?.rootViewController = UINavigationController.init(rootViewController: ViewController.init());
        window?.makeKeyAndVisible();
        return true
    }


}

