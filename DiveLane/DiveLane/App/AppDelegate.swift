//
//  AppDelegate.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var controller: AppController!
    let transactionsService: ITransactionsService = TransactionsService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        CurrentNetwork.currentNetwork = (UserDefaults.standard.object(forKey: "currentNetwork") as? Networks) ?? Networks.Mainnet
        CurrentWeb.currentWeb = (UserDefaults.standard.object(forKey: "currentWeb") as? web3) ?? Web3.InfuraMainnetWeb3()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        controller = AppController(window: window!, launchOptions: launchOptions, url: nil)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
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


