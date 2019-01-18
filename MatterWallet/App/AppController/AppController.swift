//
//  AppController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import BigInt

public class AppController {

    private let etherscanService = ContractsService()
    private let walletsService = WalletsService()
    private let routerEIP681 = EIP681Router()
    private let plasmaRouter = PlasmaRouter()
    private let userDefaultKeys = UserDefaultKeys()
    private let tokensService = TokensService()
    private let networksService = NetworksService()

    convenience init(
            window: UIWindow,
            launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
            url: URL?) {
        self.init()
        start(in: window, launchOptions: launchOptions, url: url)
    }

    private func start(in window: UIWindow, launchOptions: [UIApplication.LaunchOptionsKey: Any]?, url: URL?) {
        if let launchOptions = launchOptions {
            if let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
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
    
    public func onboardingController() -> UINavigationController {
        let vc = OnboardingViewController()
        let nav = navigationController(withTitle: "Onboarding",
                                                      withImage: nil,
                                                      withController: vc,
                                                      tag: 0)
        return nav
    }
    
    public func createPincodeController() -> UINavigationController {
        let vc = CreatePincodeViewController()
        let nav = navigationController(withTitle: "Create Pincode",
                                                      withImage: nil,
                                                      withController: vc,
                                                      tag: 0)
        return nav
    }

    public func addWalletController() -> UINavigationController {
        let vc = AddWalletViewController(isNavigationBarNeeded: false)
        let nav = navigationController(withTitle: "Add Wallet",
                                                      withImage: nil,
                                                      withController: vc,
                                                      tag: 0)
        return nav
    }

    public func goToApp() -> UITabBarController {
        let tabs = UITabBarController()
        let nav1 = navigationController(withTitle: "Wallet",
                                        withImage: UIImage(named: "wallet_white"),
                                        withController: WalletViewController(nibName: nil, bundle: nil),
                                        tag: 1)
//        let nav2 = navigationController(withTitle: "Transactions History",
//                                        withImage: UIImage(named: "transactions_gray"),
//                                        withController: TransactionsHistoryViewController(),
//                                        tag: 2)
        let nav4 = navigationController(withTitle: "Settings",
                                        withImage: UIImage(named: "settings_white"),
                                        withController: SettingsViewController(nibName: nil, bundle: nil),
                                        tag: 4)
        let nav3 = navigationController(withTitle: "Contacts",
                                        withImage: UIImage(named: "contacts_white"),
                                        withController: ContactsViewController(nibName: nil, bundle: nil),
                                        tag: 3)
        tabs.tabBar.barTintColor = Colors.firstMain
        tabs.tabBar.tintColor = Colors.secondMain
        tabs.tabBar.unselectedItemTintColor = Colors.active
        
        tabs.viewControllers = [nav1, nav3, nav4]

        return tabs
    }
    
    private func initPreparations(for wallet: Wallet, on network: Web3Network) {
        let group = DispatchGroup()
        
        let tokensDownloaded = userDefaultKeys.areTokensDownloaded
        let etherAdded = userDefaultKeys.isEtherAdded(for: wallet)
        
        CurrentWallet.currentWallet = wallet
        CurrentNetwork.currentNetwork = network
        
        group.enter()
        DispatchQueue.global().async { [unowned self] in
            if !tokensDownloaded {
                do {
                    try self.tokensService.downloadAllAvailableTokensIfNeeded()
                    self.userDefaultKeys.setTokensDownloaded()
                    group.leave()
                } catch let error {
                    fatalError("Can't download tokens - \(String(describing: error))")
                }
            } else {
                group.leave()
            }
        }
        
        group.enter()
        DispatchQueue.global().async { [unowned self] in
            if !etherAdded {
                do {
                    try self.addFirstToken(for: wallet)
                    group.leave()
                } catch let error {
                    fatalError("Can't add ether token - \(String(describing: error))")
                }
            } else {
                if let token = try? wallet.getSelectedToken(network: network) {
                    CurrentToken.currentToken = token
                    group.leave()
                } else {
                    CurrentToken.currentToken = ERC20Token(ether: true)
                    group.leave()
                }
            }
        }
        group.wait()
    }

    private func startAsUsual(in window: UIWindow) {

        var startViewController: UIViewController
        
        let selectedNetwork: Web3Network
        if let sn = try? self.networksService.getSelectedNetwork() {
            selectedNetwork = sn
        } else {
            let mainnet = Web3Network(network: .Mainnet)
            selectedNetwork = mainnet
        }

        let onboardingPassed = userDefaultKeys.isOnboardingPassed
        if !onboardingPassed {
            startViewController = self.onboardingController()
            self.createRootViewController(startViewController, in: window)
            return
        }
        
        let pincodeExists = userDefaultKeys.isPincodeExists
        if !pincodeExists {
            startViewController = self.createPincodeController()
            self.createRootViewController(startViewController, in: window)
            return
        }
        
        if let walletsExists = try? walletsService.getAllWallets(), let firstWallet = walletsExists.first {
            if let selectedWallet = try? walletsService.getSelectedWallet() {
                self.initPreparations(for: selectedWallet, on: selectedNetwork)
                startViewController = self.goToApp()
                self.createRootViewController(startViewController, in: window)
                return
            } else {
                self.initPreparations(for: firstWallet, on: selectedNetwork)
                startViewController = self.goToApp()
                self.createRootViewController(startViewController, in: window)
                return
            }
        } else {
            startViewController = self.addWalletController()
            self.createRootViewController(startViewController, in: window)
            return
        }
    }
    
    private func createRootViewController(_ vc: UIViewController, in window: UIWindow) {
        DispatchQueue.main.async {
            vc.view.backgroundColor = Colors.firstMain
            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
    }
    
    public func addFirstToken(for wallet: Wallet) throws {
        let ether = ERC20Token(ether: true)
        
        for networkID in 1...42 {
            do {
                try wallet.add(token: ether,
                               network: Web3Network(network: Networks.fromInt(networkID) ?? .Mainnet))
            } catch let error {
                throw error
            }
        }
        CurrentToken.currentToken = ether
        self.userDefaultKeys.setEtherAdded(for: wallet)
    }
    
    private func navigateViaDeepLink(url: URL, in window: UIWindow) {
        if url.absoluteString.hasPrefix("ethereum:") {
            guard let parsed = Web3.EIP681CodeParser.parse(url.absoluteString) else { return }
            switch parsed.isPayRequest {
            case false:
                //Custom transaction
                routerEIP681.sendCustomTransaction(parsed: parsed, usingWindow: window)
            case true:
                //Regular sending of ETH
                routerEIP681.sendETHTransaction(parsed: parsed, usingWindow: window)
            }
        } else if url.absoluteString.hasPrefix("plasma:") {
            guard let parsed = PlasmaParser.parse(url.absoluteString) else { return }
            plasmaRouter.sendCustomTransaction(parsed: parsed, usingWindow: window)
        }
    }
}
