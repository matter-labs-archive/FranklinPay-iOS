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
    private let userDefaultKeys = UserDefaultKeys()
    private let tokensService = TokensService()
    private let networksService = NetworksService()

    convenience init(
            window: UIWindow,
            url: URL?) {
        self.init()
        start(in: window, url: url)
    }

    private func start(in window: UIWindow, url: URL?) {
        if let url = url {
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
    
    public func acceptChequeController(cheque: PlasmaCode) -> UINavigationController {
        let vc = AcceptChequeController(cheque: cheque)
        let nav = navigationController(withTitle: "Accept cheque",
                                       withImage: nil,
                                       withController: vc,
                                       tag: 0)
        return nav
    }
    
    public func enterPincodeController() -> UINavigationController {
        let vc = EnterPincodeViewController(for: EnterPincodeCases.enterWallet, data: Data())
        let nav = navigationController(withTitle: "Enter Pincode",
                                       withImage: nil,
                                       withController: vc,
                                       tag: 0)
        return nav
    }
    
//    public func walletCreationVC() -> UINavigationController {
//        let vc = WalletCreationAnimationViewController()
//        let nav = navigationController(withTitle: "Creating wallet",
//                                       withImage: nil,
//                                       withController: vc,
//                                       tag: 0)
//        return nav
//    }

//    public func addWalletController() -> UINavigationController {
//        let vc = AddWalletViewController(isNavigationBarNeeded: false)
//        let nav = navigationController(withTitle: "Add Wallet",
//                                       withImage: nil,
//                                       withController: vc,
//                                       tag: 0)
//        return nav
//    }

    public func goToApp() -> UINavigationController {
//    public func goToApp() -> SWRevealViewController {
//        let frontController:UINavigationController
//        let rearController:UINavigationController
//        let revealController = SWRevealViewController()
//        var mainRevealController = SWRevealViewController()
        
        let nav = UINavigationController()
        let tabs = TabBarController()
        let nav1 = navigationController(withTitle: nil,
                                        withImage: UIImage(named: "wallet"),
                                        withController: WalletViewController(nibName: nil, bundle: nil),
                                        tag: 1)
        let nav2 = navigationController(withTitle: nil,
                                        withImage: UIImage(named: "list"),
                                        withController: TransactionsHistoryViewController(nibName: nil, bundle: nil),
                                        tag: 2)
        let nav3 = navigationController(withTitle: nil,
                                        withImage: UIImage(named: "user_male"),
                                        withController: ContactsViewController(nibName: nil, bundle: nil),
                                        tag: 3)
//        let nav2 = navigationController(withTitle: "Transactions History",
//                                        withImage: UIImage(named: "transactions_gray"),
//                                        withController: TransactionsHistoryViewController(),
//                                        tag: 2)
//        let nav4 = navigationController(withTitle: "Settings",
//                                        withImage: UIImage(named: "settings_white"),
//                                        withController: SettingsViewController(nibName: nil, bundle: nil),
//                                        tag: 4)
//        let nav3 = navigationController(withTitle: "Contacts",
//                                        withImage: UIImage(named: "list"),
//                                        withController: ContactsViewController(nibName: nil, bundle: nil),
//                                        tag: 3)
        tabs.tabBar.barTintColor = Colors.background
        tabs.tabBar.tintColor = Colors.mainBlue
        tabs.tabBar.unselectedItemTintColor = Colors.otherLightGray
        
        tabs.viewControllers = [nav1, nav2, nav3]
        
        nav.viewControllers = [tabs]
        nav.setNavigationBarHidden(true, animated: false)
//        frontController = nav
//        rearController = UINavigationController(rootViewController: SettingsViewController(nibName: nil, bundle: nil))
        
//        revealController.frontViewController = frontController
//        revealController.rearViewController = rearController
//        revealController.delegate = nav as? SWRevealViewControllerDelegate
//        revealController.rearViewRevealWidth = UIScreen.main.bounds.width * 0.85
//        mainRevealController = revealController
//
//        return mainRevealController
        return nav
    }
    
    private func initPreparations(for wallet: Wallet, on network: Web3Network) {
        let group = DispatchGroup()
        
        let tokensDownloaded = userDefaultKeys.areTokensDownloaded
//        let etherAdded = userDefaultKeys.isEtherAdded(for: wallet)
//        let franklinAdded = userDefaultKeys.isFranklinAdded(for: wallet)
        
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
//        DispatchQueue.global().async { [unowned self] in
//            if !etherAdded && !franklinAdded {
//                do {
//                    try self.addEther(for: wallet)
//                    try self.addFranklin(for: wallet)
//                    group.leave()
//                } catch let error {
//                    fatalError("Can't add ether token - \(String(describing: error))")
//                }
//            } else if !franklinAdded {
//                do {
//                    try self.addFranklin(for: wallet)
//                    group.leave()
//                } catch let error {
//                    fatalError("Can't add ether token - \(String(describing: error))")
//                }
//            } else if !etherAdded {
//                do {
//                    try self.addEther(for: wallet)
//                    group.leave()
//                } catch let error {
//                    fatalError("Can't add ether token - \(String(describing: error))")
//                }
//            } else {
//                if let token = try? wallet.getSelectedToken(network: network) {
//                    CurrentToken.currentToken = token
//                    group.leave()
//                } else {
//                    CurrentToken.currentToken = ERC20Token(franklin: true)
//                    group.leave()
//                }
//            }
//        }
        if let token = try? wallet.getSelectedToken(network: network) {
            CurrentToken.currentToken = token
            group.leave()
        } else {
            CurrentToken.currentToken = ERC20Token(franklin: true)
            group.leave()
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
        
        if let selectedWallet = CurrentWallet.currentWallet {
            self.initPreparations(for: selectedWallet, on: selectedNetwork)
            if self.userDefaultKeys.isPincodeExists {
                startViewController = self.enterPincodeController()
            } else {
                startViewController = self.goToApp()
            }
            self.createRootViewController(startViewController, in: window)
        } else {
            startViewController = self.onboardingController()
            self.createRootViewController(startViewController, in: window)
        }
    }

//    private func startAsUsual(in window: UIWindow) {
//
//        var startViewController: UIViewController
//
//        let selectedNetwork: Web3Network
//        if let sn = try? self.networksService.getSelectedNetwork() {
//            selectedNetwork = sn
//        } else {
//            let mainnet = Web3Network(network: .Mainnet)
//            selectedNetwork = mainnet
//        }
//
//        let onboardingPassed = userDefaultKeys.isOnboardingPassed
//        if !onboardingPassed {
//            startViewController = self.onboardingController()
//            self.createRootViewController(startViewController, in: window)
//            return
//        }
//
//        let pincodeExists = userDefaultKeys.isPincodeExists
//        if !pincodeExists {
//            startViewController = self.createPincodeController()
//            self.createRootViewController(startViewController, in: window)
//            return
//        }
//
//        if let walletsExists = try? walletsService.getAllWallets(), let firstWallet = walletsExists.first {
//            if let selectedWallet = try? walletsService.getSelectedWallet() {
//                self.initPreparations(for: selectedWallet, on: selectedNetwork)
//                startViewController = self.goToApp()
//                self.createRootViewController(startViewController, in: window)
//                return
//            } else {
//                self.initPreparations(for: firstWallet, on: selectedNetwork)
//                startViewController = self.goToApp()
//                self.createRootViewController(startViewController, in: window)
//                return
//            }
//        } else {
//            startViewController = self.addWalletController()
//            self.createRootViewController(startViewController, in: window)
//            return
//        }
//    }
    
    private func createRootViewController(_ vc: UIViewController, in window: UIWindow) {
        DispatchQueue.main.async {
            vc.view.backgroundColor = Colors.background
            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
    }
    
    public func addEther(for wallet: Wallet) throws {
        let ether = ERC20Token(ether: true)
        
        for networkID in 1...42 {
            do {
                try wallet.add(token: ether,
                               network: Web3Network(network: Networks.fromInt(networkID) ?? .Mainnet))
            } catch let error {
                throw error
            }
        }
        self.userDefaultKeys.setEtherAdded(for: wallet)
    }
    
    public func addFranklin(for wallet: Wallet) throws {
        let franklin = ERC20Token(franklin: true)
        
        for networkID in 1...42 {
            do {
                try wallet.add(token: franklin,
                               network: Web3Network(network: Networks.fromInt(networkID) ?? .Mainnet))
            } catch let error {
                throw error
            }
        }
        CurrentToken.currentToken = franklin
        self.userDefaultKeys.setEtherAdded(for: wallet)
    }
    
    private func navigateViaDeepLink(url: URL, in window: UIWindow) {
        if url.absoluteString.hasPrefix("ethereum:") {
            // TODO :- ether deeplink
//            guard let parsed = Web3.EIP681CodeParser.parse(url.absoluteString) else { return }
//            switch parsed.isPayRequest {
//            case false:
//                //Custom transaction
//                routerEIP681.sendCustomTransaction(parsed: parsed, usingWindow: window)
//            case true:
//                //Regular sending of ETH
//                routerEIP681.sendETHTransaction(parsed: parsed, usingWindow: window)
//            }
        } else if url.absoluteString.hasPrefix("plasma:") {
            if let parsed = PlasmaParser.parse(url.absoluteString) {
                let vc = self.acceptChequeController(cheque: parsed)
                self.createRootViewController(vc, in: window)
            } else {
                startAsUsual(in: window)
            }
        }
    }
}
