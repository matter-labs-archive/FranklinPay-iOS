//
//  AppController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class AppController {
    
    convenience init(
        window: UIWindow
        ) {
        self.init()
        start(in: window)
    }
    
    func start(in window: UIWindow) {
        var startViewController: UIViewController
        
        let isOnboardingPassed = UserDefaults.standard.bool(forKey: "isOnboardingPassed")
        let existingWallet = LocalDatabase().getWallet()
        
        if !isOnboardingPassed {
            startViewController = OnboardingViewController()
            startViewController.view.backgroundColor = UIColor.white
        } else if existingWallet == nil {
            startViewController = addWallet()
            startViewController.view.backgroundColor = UIColor.white
        } else {
            startViewController = goToApp()
            startViewController.view.backgroundColor = UIColor.white
        }
        window.rootViewController = startViewController
        window.makeKeyAndVisible()
    }
    
    func addWallet() -> UINavigationController {
        let nav = UINavigationController()
        let addWalletViewController = AddWalletViewController(nibName: "AddWalletViewController", bundle: nil)
        nav.viewControllers.append(addWalletViewController)
        
        return nav
    }
    
    func goToApp() -> UITabBarController {
        var nav1 = UINavigationController()
        var first = WalletViewController(nibName: nil, bundle: nil)
        nav1.viewControllers = [first]
        nav1.tabBarItem = UITabBarItem(title: nil, image: UIImage(named:"user"), tag: 1)
        
        var nav2 = UINavigationController()
        var second = SecondViewController(nibName: nil, bundle: nil)
        nav2.viewControllers = [second]
        nav2.tabBarItem = UITabBarItem(title: nil, image: UIImage(named:"settings"), tag: 2)
        
        var tabs = UITabBarController()
        tabs.viewControllers = [nav1, nav2]
        
        return tabs
    }
    
}

