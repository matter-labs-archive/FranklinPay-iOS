//
//  AppController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class AppController {
    
    let parser = Parser()
    let transactionsService = TransactionsService()
    
    convenience init(
        window: UIWindow,
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
        url: URL?) {
        self.init()
        start(in: window, launchOptions: launchOptions, url: url)
    }
    
    func start(in window: UIWindow, launchOptions: [UIApplicationLaunchOptionsKey: Any]?, url: URL?) {
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
    
    func startAsUsual(in window: UIWindow) {
        
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
    
    private func navigateViaDeepLink(url: URL, in window: UIWindow) {
        guard let index = url.absoluteString.index(of: ":") else { return }
        let i = url.absoluteString.index(index, offsetBy: 1)
        let parsedUrl = parser.genericlyParseURLethereum(url: String(url.absoluteString[i...]))
        if let parsedUrl = parsedUrl {
            switch parsedUrl.type {
            case .arbitraryMethodWithParams:
                let controller = SendArbitraryTransactionViewController(params: parsedUrl.parametersView!, transactionInfo: TransactionInfo(contractAddress: parsedUrl.tokenAddress!.address, methodName: parsedUrl.methodName!))
                window.rootViewController = controller
                window.makeKeyAndVisible()
//                transactionsService.prepareTransactionToContract(data: parsedUrl.parameters!, contractAbi: parsedUrl.contractAbi!, contractAddress: parsedUrl.tokenAddress!.address, method: parsedUrl.methodName!, amountString: "0") { (result) in
//                    switch result {
//                    case .Error(let error):
//                        print(error)
//                    case .Success(let intermediate):
//                        let controller = SendArbitraryTransactionViewController(params: parsedUrl.parametersView!, transactionInfo: TransactionInfo(contractAddress: parsedUrl.tokenAddress!.address, transactionIntermediate: intermediate, methodName: parsedUrl.methodName!))
//                        window.rootViewController = controller
//                        window.makeKeyAndVisible()
//                    }
//                }
            case .custom:
                print("TODO")
            }
        }
    }
    
}

