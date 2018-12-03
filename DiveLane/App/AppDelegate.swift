//
//  AppDelegate.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var controller: AppController!
    let transactionsService = Web3Service()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        window = UIWindow(frame: UIScreen.main.bounds)

        controller = AppController(window: window!, launchOptions: launchOptions, url: nil)

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        controller = AppController(window: window!, launchOptions: nil, url: url)
        return true
    }

}

func addWallet() -> UINavigationController {
    let nav = UINavigationController()
    let addWalletViewController = AddWalletViewController()
    //addWalletViewController.title = "Add Wallet"
    nav.viewControllers.append(addWalletViewController)

    return nav
}
