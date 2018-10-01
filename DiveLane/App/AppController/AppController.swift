//
//  AppController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift
import struct BigInt.BigUInt

class AppController {

    let transactionsService = TransactionsService()
    let etherscanService = EtherscanService()
    let localDatabase = LocalDatabase()
    let routerEIP681 = EIP681Router()

    convenience init(
            window: UIWindow,
            launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
            url: URL?) {
        self.init()
        start(in: window, launchOptions: launchOptions, url: url)
    }

    func start(in window: UIWindow, launchOptions: [UIApplicationLaunchOptionsKey: Any]?, url: URL?) {
        selectNetwork()
        if let launchOptions = launchOptions {
            if let url = launchOptions[UIApplicationLaunchOptionsKey.url] as? URL {
                navigateViaDeepLink(url: url, in: window)
            } else {
                startAsUsual(in: window)
            }
        } else if let url = url {
            navigateViaDeepLink(url: url, in: window)
        } else {
            startAsUsual(in: window)
        }

    }

    func addWallet() -> UINavigationController {
        let nav = UINavigationController()
        let addWalletViewController = AddWalletViewController()
        nav.viewControllers.append(addWalletViewController)

        return nav
    }

    func goToApp() -> UITabBarController {
        let tabs = UITabBarController()
        selectWallet { [unowned self] (wallet) in
            if let wallet = wallet {
                self.selectToken(for: wallet)
            }
        }
        let nav1 = navigationController(withTitle: "Wallet",
                withImage: UIImage(named: "wallet"),
                withController: WalletViewController(nibName: nil, bundle: nil),
                tag: 1)
        let nav2 = navigationController(withTitle: "Settings",
                withImage: UIImage(named: "settings"),
                withController: SettingsViewController(nibName: nil, bundle: nil),
                tag: 2)
        let nav3 = navigationController(withTitle: "Transactions History",
                withImage: UIImage(named: "history"),
                withController: TransactionsHistoryViewController(),
                tag: 3)
        let nav4 = navigationController(withTitle: "Send",
                withImage: UIImage(named: "send"),
                withController: SendSettingsViewController(),
                tag: 4)
        tabs.viewControllers = [nav1, nav3, nav2, nav4]

        return tabs
    }

    func navigationController(withTitle: String?, withImage: UIImage?,
                              withController: UIViewController,
                              tag: Int) -> UINavigationController {
        let nav = UINavigationController()
        //nav.navigationBar.barTintColor = Colors.NavBarColors.mainTint
        //nav.navigationBar.tintColor = UIColor.black
        //nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        //nav.navigationBar.barStyle = .default
        let controller = withController
        controller.title = withTitle
        nav.viewControllers = [controller]
        nav.tabBarItem = UITabBarItem(title: nil, image: withImage, tag: tag)
        return nav
    }
    
    func startAsUsual(in window: UIWindow) {

        var startViewController: UIViewController?

        let isOnboardingPassed = UserDefaultKeys().isOnboardingPassed
        let existingWallet = LocalDatabase().getWallet()

        if !isOnboardingPassed {
            startViewController = OnboardingViewController()
            startViewController?.view.backgroundColor = Colors.BackgroundColors.main
        } else if existingWallet == nil {
            startViewController = addWallet()
            startViewController?.view.backgroundColor = UIColor.white
        } else {
            DispatchQueue.global().async {
                if !UserDefaultKeys().tokensDownloaded {
                    TokensService().downloadAllAvailableTokensIfNeeded(completion: { (error) in
                        if error == nil {
                            UserDefaultKeys().setTokensDownloaded()
                            UserDefaults.standard.synchronize()
                        }
                    })
                }
            }
            DispatchQueue.global().async { [unowned self] in
                if !UserDefaultKeys().isEtherAdded {
                    guard let wallet = KeysService().selectedWallet() else {
                        return
                    }
                    self.addFirstToken(for: wallet, completion: { (error) in
                        if error == nil {
                            UserDefaultKeys().setEtherAdded()
                            UserDefaults.standard.synchronize()

                        } else {
                            //fatalError("Can't add ether - \(String(describing: error))")
                        }
                    })
                }
            }
            startViewController = self.goToApp()
            startViewController?.view.backgroundColor = UIColor.white

        }
        window.rootViewController = startViewController ?? UIViewController()
        window.makeKeyAndVisible()

    }
    func selectNetwork() {
        CurrentNetwork.currentNetwork = (UserDefaultKeys().currentNetwork as? Networks) ?? Networks.Mainnet
        CurrentWeb.currentWeb = (UserDefaultKeys().currentWeb as? web3) ?? Web3.InfuraMainnetWeb3()
    }
    func selectWallet(completion: @escaping (KeyWalletModel?) -> Void) {
        guard let firstWallet = LocalDatabase().getWallet() else {
            completion(nil)
            return
        }
        completion(firstWallet)

    }
    func selectToken(for wallet: KeyWalletModel) {
        localDatabase.selectWallet(wallet: wallet) {
            let token = self.localDatabase.getAllTokens(for: wallet,
                                                   forNetwork: Int64(CurrentNetwork.currentNetwork?.chainID ?? 1)).first
            CurrentToken.currentToken = token
        }
    }
    func addFirstToken(for wallet: KeyWalletModel, completion: @escaping (Error?) -> Void) {
        let currentNetworkID = Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
        for networkID in 1...42 {
            let etherToken = ERC20TokenModel(isEther: true)
            localDatabase.saveCustomToken(with: etherToken,
                                          forWallet: wallet,
                                          forNetwork: Int64(networkID)) { (error) in
                if error == nil && Int64(networkID) == currentNetworkID {
                    CurrentToken.currentToken = etherToken
                } else if error != nil && Int64(networkID) == currentNetworkID {
                    completion(error)
                }
                if networkID == 42 {
                    completion(error)
                }
            }
        }
    }
    private func navigateViaDeepLink(url: URL, in window: UIWindow) {
        guard let parsed = Web3.EIP681CodeParser.parse(url.absoluteString) else { return }
        switch parsed.isPayRequest {
        case false:
            //Custom transaction
            routerEIP681.sendCustomTransaction(parsed: parsed, usingWindow: window)
        case true:
            //Regular sending of ETH
            routerEIP681.sendETHTransaction(parsed: parsed, usingWindow: window)
        }
    }
}
