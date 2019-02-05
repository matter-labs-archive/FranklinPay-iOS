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
import StatusBarOverlay

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var controller: AppController!
    
    let userDefaultKeys = UserDefaultKeys()
    let tokensService = TokensService()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        StatusBarOverlay.host = "https://etherscan.io/"
        window = UIWindow(frame: UIScreen.main.bounds)
        //downloadTokens()
        controller = AppController(window: window!, url: nil)
        //controller = AppController(window: window!, launchOptions: nil, url: URL(string: "plasma:0x0A8dF54352eB4Eb6b18d0057B15009732EfB351c/split?chainId=4&value=0.3")!)
        return true
//        Fabric.with([Crashlytics.self])
//        StatusBarOverlay.host = "https://etherscan.io/"
//        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
//        controller = AppController(window: window, url: URL(string: "plasma://franklin.network/cheque?number=1&from=0x0A8dF54352eB4Eb6b18d0057B15009732EfB351c&amount=0.3"))
//        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Fabric.with([Crashlytics.self])
        StatusBarOverlay.host = "https://etherscan.io/"
        let window = self.window ?? UIWindow(frame: UIScreen.main.bounds)
        controller = AppController(window: window, url: url)
        return true
    }
    
    func downloadTokens() {
        let tokensDownloaded = userDefaultKeys.areTokensDownloaded
        DispatchQueue.global().async { [unowned self] in
            if !tokensDownloaded {
                do {
                    try self.tokensService.downloadAllAvailableTokensIfNeeded()
                    self.userDefaultKeys.setTokensDownloaded()
                } catch let error {
                    fatalError("Can't download tokens - \(String(describing: error))")
                }
            }
        }
    }
}
