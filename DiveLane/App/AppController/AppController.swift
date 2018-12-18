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

class AppController {

    let transactionsService = Web3Service()
    let etherscanService = ContractsService()
    let localDatabase = WalletsStorage()
    let routerEIP681 = EIP681Router()
    let plasmaRouter = PlasmaRouter()

    convenience init(
            window: UIWindow,
            launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
            url: URL?) {
        self.init()
        start(in: window, launchOptions: launchOptions, url: url)
    }

    func start(in window: UIWindow, launchOptions: [UIApplication.LaunchOptionsKey: Any]?, url: URL?) {
        selectNetwork()
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
                                        withImage: UIImage(named: "wallet_gray"),
                                        withController: WalletViewController(nibName: nil, bundle: nil),
                                        tag: 1)
        let nav2 = navigationController(withTitle: "Send",
                                        withImage: UIImage(named: "send_gray"),
                                        withController: SendSettingsViewController(),
                                        tag: 2)
        let nav3 = navigationController(withTitle: "Transactions History",
                                        withImage: UIImage(named: "transactions_gray"),
                                        withController: TransactionsHistoryViewController(),
                                        tag: 3)
//        let nav4 = navigationController(withTitle: "Settings",
//                                        withImage: UIImage(named: "settings_gray"),
//                                        withController: SettingsViewController(nibName: nil, bundle: nil),
//                                        tag: 4)
        let nav4 = navigationController(withTitle: "Contacts",
                                        withImage: UIImage(named: "contacts_gray"),
                                        withController: ContactsViewController(nibName: nil, bundle: nil),
                                        tag: 4)
        let nav5 = navigationController(withTitle: "Browser",
                                        withImage: UIImage(named: "deselected"),
                                        withController: BrowserController(nibName: nil, bundle: nil),
                                        tag: 5)
        tabs.viewControllers = [nav1, nav3, nav2, nav4, nav5]

        return tabs
    }

    func navigationController(withTitle: String?, withImage: UIImage?,
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

    func startAsUsual(in window: UIWindow) {

        var startViewController: UIViewController?

        let isOnboardingPassed = UserDefaultKeys().isOnboardingPassed
        let wallet: WalletModel?
        do {
            let w = try localDatabase.getSelectedWallet()
            wallet = w
        } catch {
            wallet = nil
        }

        if !isOnboardingPassed {
            startViewController = OnboardingViewController()
            startViewController?.view.backgroundColor = Colors.BackgroundColors.main
        } else if wallet == nil {
            startViewController = addWallet()
            startViewController?.view.backgroundColor = UIColor.white
        } else {
            DispatchQueue.global().async {
                if !UserDefaultKeys().tokensDownloaded {
                    do {
                        try TokensService().downloadAllAvailableTokensIfNeeded()
                        UserDefaultKeys().setTokensDownloaded()
                        UserDefaults.standard.synchronize()
                    } catch let error {
                        fatalError("Can't download tokens - \(String(describing: error))")
                    }
                }
            }
            DispatchQueue.global().async { [unowned self] in
                if !UserDefaultKeys().isEtherAdded {
                    do {
                        let wallet = try self.localDatabase.getSelectedWallet()
                        self.addFirstToken(for: wallet, completion: { (error) in
                            if error == nil {
                                UserDefaultKeys().setEtherAdded()
                                UserDefaults.standard.synchronize()
                                
                            } else {
                                fatalError("Can't add ether - \(String(describing: error))")
                            }
                        })
                    } catch let error {
                        fatalError("Can't get wallet - \(String(describing: error))")
                    }
                }
            }
            startViewController = self.goToApp()
            startViewController?.view.backgroundColor = UIColor.white
        }
        DispatchQueue.main.async {
            window.rootViewController = startViewController ?? UIViewController()
            window.makeKeyAndVisible()
        }
    }
    
    func selectNetwork() {
        CurrentNetwork.currentNetwork = (UserDefaultKeys().currentNetwork as? Networks) ?? Networks.Mainnet
        CurrentWeb.currentWeb = (UserDefaultKeys().currentWeb as? web3) ?? Web3.InfuraMainnetWeb3()
    }
    
    func selectWallet(completion: @escaping (WalletModel?) -> Void) {
        guard let firstWallet = try? localDatabase.getSelectedWallet() else {
            completion(nil)
            return
        }
        completion(firstWallet)

    }
    
    func selectToken(for wallet: WalletModel) {
        do {
            try localDatabase.selectWallet(wallet: wallet)
            let token = try TokensStorage().getAllTokens(for: wallet, networkId: Int64(CurrentNetwork.currentNetwork.chainID)).first
            CurrentToken.currentToken = token
        } catch let error {
            fatalError("Can't select token - \(String(describing: error))")
        }
    }
    
    func addFirstToken(for wallet: WalletModel, completion: @escaping (Error?) -> Void) {
        let currentNetworkID = Int64(String(CurrentNetwork.currentNetwork.chainID )) ?? 0
        for networkID in 1...42 {
            let etherToken = ERC20TokenModel(isEther: true)
            do {
                try TokensStorage().saveCustomToken(token: etherToken,
                                            wallet: wallet,
                                            networkId: Int64(networkID))
            } catch let error {
                completion(error)
            }
            if Int64(networkID) == currentNetworkID {
                CurrentToken.currentToken = etherToken
            }
        }
        completion(nil)
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
