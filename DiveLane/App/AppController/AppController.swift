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
    private let onboarding = OnboardingViewController()

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

    private func addWalletController() -> UINavigationController {
        let nav = UINavigationController()
        let addWalletViewController = AddWalletViewController()
        nav.viewControllers.append(addWalletViewController)

        return nav
    }

    private func goToApp() -> UITabBarController {
        let tabs = UITabBarController()
        let nav1 = navigationController(withTitle: "Wallet",
                                        withImage: UIImage(named: "wallet_gray"),
                                        withController: WalletViewController(nibName: nil, bundle: nil),
                                        tag: 1)
        let nav2 = navigationController(withTitle: "Transactions History",
                                        withImage: UIImage(named: "transactions_gray"),
                                        withController: TransactionsHistoryViewController(),
                                        tag: 2)
        let nav4 = navigationController(withTitle: "Settings",
                                        withImage: UIImage(named: "settings_gray"),
                                        withController: SettingsViewController(nibName: nil, bundle: nil),
                                        tag: 4)
        let nav3 = navigationController(withTitle: "Contacts",
                                        withImage: UIImage(named: "contacts_gray"),
                                        withController: ContactsViewController(nibName: nil, bundle: nil),
                                        tag: 3)
        tabs.viewControllers = [nav1, nav2, nav3, nav4]

        return tabs
    }

    private func navigationController(withTitle: String?, withImage: UIImage?,
                              withController: UIViewController,
                              tag: Int) -> UINavigationController {
        let nav = UINavigationController()
        nav.navigationBar.barTintColor = Colors.NavBarColors.mainTint
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        nav.navigationBar.barStyle = .black
        let controller = withController
        controller.title = withTitle
        nav.viewControllers = [controller]
        nav.tabBarItem = UITabBarItem(title: nil, image: withImage, tag: tag)
        return nav
    }
    
    private func initPreparations(for wallet: Wallet) {
        let group = DispatchGroup()
        group.enter()
        
        let tokensDownloaded = userDefaultKeys.tokensDownloaded
        let etherAdded = userDefaultKeys.etherAdded
        
        
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
        DispatchQueue.global().async { [unowned self] in
            if !etherAdded {
                self.addFirstToken(for: wallet)
                self.userDefaultKeys.setEtherAdded()
            }
        }
    }

    private func startAsUsual(in window: UIWindow) {

        var startViewController: UIViewController

        let onboardingPassed = userDefaultKeys.onboardingPassed
        if !onboardingPassed {
            startViewController = self.onboarding
        }
        
        guard let walletsExists = try? walletsService.getAllWallets(), let firstWallet = walletsExists.first else {
            startViewController = self.addWalletController()
        }
        
        if let selectedWallet = try? walletsService.getSelectedWallet() {
            self.initPreparations(for: selectedWallet)
            startViewController = self.goToApp()
        } else {
            do {
                try firstWallet.select()
                self.initPreparations(for: firstWallet)
                startViewController = self.goToApp()
            } catch let error {
                fatalError("Can't select existing wallet \(firstWallet.address), error: \(error.localizedDescription)")
            }
        }
        startViewController.view.backgroundColor = UIColor.white
        DispatchQueue.main.async {
            window.rootViewController = startViewController
            window.makeKeyAndVisible()
        }
    }
    
    func addFirstToken(for wallet: Wallet) {
        let group = DispatchGroup()
        group.enter()
        
        let ether = ERC20Token(ether: true)
        
        for networkID in 1...42 {
            do {
                try wallet.add(token: ether,
                               network: Web3Network(network: Networks.fromInt(networkID) ?? .Mainnet))
            } catch let error {
                print("Can't add ether for \(wallet.address) on \(networkID), error: \(error.localizedDescription)")
                continue
            }
        }
        CurrentToken.currentToken = ether
        group.leave()
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
