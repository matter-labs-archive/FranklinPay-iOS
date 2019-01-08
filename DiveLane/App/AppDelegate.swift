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

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])

        window = UIWindow(frame: UIScreen.main.bounds)

        controller = AppController(window: window!, launchOptions: launchOptions, url: nil)
        //controller = AppController(window: window!, launchOptions: nil, url: URL(string: "plasma:0x0A8dF54352eB4Eb6b18d0057B15009732EfB351c/split?chainId=4&value=0.3")!)

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Fabric.with([Crashlytics.self])
        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        controller = AppController(window: window, launchOptions: nil, url: url)
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
