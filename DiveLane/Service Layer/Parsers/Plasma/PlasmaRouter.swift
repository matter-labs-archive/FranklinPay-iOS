//
//  PlasmaRouter.swift
//  DiveLane
//
//  Created by Anton Grigorev on 07/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import EthereumAddress
import BigInt

public final class PlasmaRouter {
    let model = PlasmaParserModel()
    public func sendCustomTransaction(parsed: PlasmaCode, usingWindow window: UIWindow) {
        switch parsed.txType {
        case .split:
            splitTransaction(parsed: parsed, usingWindow: window)
        default:
            print("Something goes wrong")
        }
    }
    
    public func splitTransaction(parsed: PlasmaCode, usingWindow window: UIWindow) {
        print("yay")
        guard let amount = parsed.amount else {return}
        let targetAddress = parsed.targetAddress
        guard let chainId = parsed.chainID else {return}
        switch chainId {
        case 1:
            CurrentNetwork.currentNetwork = .Mainnet
        case 4:
            CurrentNetwork.currentNetwork = .Rinkeby
        default:
            print("wrong network")
            return
        }
        let controller = SendSettingsViewController(amount: amount, destinationAddress: targetAddress.address, isFromDeepLink: true)
        showController(controller, window: window)
        
    }
    
    private func showController(_ controller: UIViewController, window: UIWindow) {
        let tabs = self.goToApp(controller: controller)
        DispatchQueue.main.async {
            tabs.view.backgroundColor = UIColor.white
            tabs.selectedIndex = 2
            window.rootViewController = tabs
            window.makeKeyAndVisible()
        }
    }
    
    private func navigationController(withTitle: String?, withImage: UIImage?,
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
    
    private func goToApp(controller: UIViewController) -> UITabBarController {
        let tabs = UITabBarController()
        let nav1 = navigationController(withTitle: "Wallet",
                                        withImage: UIImage(named: "wallet_gray"),
                                        withController: WalletViewController(nibName: nil, bundle: nil),
                                        tag: 1)
        let nav2 = navigationController(withTitle: "Send",
                                        withImage: UIImage(named: "send_gray"),
                                        withController: controller,
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
                                        withImage: UIImage(named: "AppIcon"),
                                        withController: BrowserController(nibName: nil, bundle: nil),
                                        tag: 5)
        tabs.viewControllers = [nav1, nav3, nav2, nav4, nav5]
        
        return tabs
    }
}
