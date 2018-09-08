//
//  AppController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift
let peepEthAbi = """
[ { "constant": false, "inputs": [ { "name": "_followee", "type": "address" } ], "name": "unFollow", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "updateAccount", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "isActive", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_isActive", "type": "bool" } ], "name": "setIsActive", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_followee", "type": "address" } ], "name": "follow", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_name", "type": "bytes16" } ], "name": "changeName", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "address" } ], "name": "names", "outputs": [ { "name": "", "type": "bytes32" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "reply", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "bytes32" } ], "name": "addresses", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_address", "type": "address" } ], "name": "setNewAddress", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [ { "name": "_addr", "type": "address" } ], "name": "accountExists", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [ { "name": "bStr", "type": "bytes16" } ], "name": "isValidName", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "pure", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "share", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "saveBatch", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [], "name": "cashout", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "owner", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "post", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_name", "type": "bytes16" }, { "name": "_ipfsHash", "type": "string" } ], "name": "createAccount", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "newMinPercentage", "type": "uint256" } ], "name": "setMinSiteTipPercentage", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_author", "type": "address" }, { "name": "_messageID", "type": "string" }, { "name": "_ownerTip", "type": "uint256" }, { "name": "_ipfsHash", "type": "string" } ], "name": "tip", "outputs": [], "payable": true, "stateMutability": "payable", "type": "function" }, { "constant": true, "inputs": [], "name": "newAddress", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "uint256" } ], "name": "interfaceInstances", "outputs": [ { "name": "interfaceAddress", "type": "address" }, { "name": "startBlock", "type": "uint96" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_address", "type": "address" } ], "name": "transferAccount", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [], "name": "lockMinSiteTipPercentage", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "interfaceInstanceCount", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "minSiteTipPercentage", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "newOwner", "type": "address" } ], "name": "transferOwnership", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "tipPercentageLocked", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor" }, { "payable": true, "stateMutability": "payable", "type": "fallback" }, { "anonymous": false, "inputs": [], "name": "PeepethEvent", "type": "event" } ]
"""
class AppController {
    
    let parser = Parser()
    let transactionsService = TransactionsService()
    let etherscanService = EtherscanService()
    
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
        let nav1 = UINavigationController()
        let first = WalletViewController(nibName: nil, bundle: nil)
        first.title = "Wallet"
        nav1.viewControllers = [first]
        nav1.tabBarItem = UITabBarItem(title: nil, image: UIImage(named:"user"), tag: 1)
        
        let nav2 = UINavigationController()
        let second = SettingsViewController(nibName: nil, bundle: nil)
        second.title = "Settings"
        nav2.viewControllers = [second]
        nav2.tabBarItem = UITabBarItem(title: nil, image: UIImage(named:"settings"), tag: 2)
        
        let tabs = UITabBarController()
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
        guard let parsed = Web3.EIP681CodeParser.parse(url.absoluteString) else { return }
//        let fun = ABIv2.Element.function(parsed.function!)
//        let data = fun.encodeParameters(parsed.parameters.compactMap{return $0.value})
//        print(    data?.toHexString())
        switch parsed.isPayRequest {
        case false:
            guard case .ethereumAddress(let contractAddress) = parsed.targetAddress else { return }
            guard let methodName = parsed.functionName else { return }
            let params = parsed.params.map {
                return Parameter(type: $0.0, value: $0.1)
            }
            etherscanService.getAbi(forContractAddress: contractAddress.address) { (result) in
                switch result {
                case .Success(let abi):
                    self.transactionsService.prepareTransactionToContract(data: parsed.parameters.map{ return $0.value }, contractAbi: abi, contractAddress: contractAddress.address, method: methodName, amountString: "", amount: parsed.amount ?? 0) { (result) in
                        switch result {
                        case .Error(let error):
                            print(error)
                        case .Success(let intermediate):
                            let controller = SendArbitraryTransactionViewController(params: parsed.params.map{return Parameter(type: $0.0, value: $0.1)}, transactionInfo: TransactionInfo(contractAddress: contractAddress.address, transactionIntermediate: intermediate, methodName: methodName))
                            window.rootViewController = controller
                            window.makeKeyAndVisible()
                        }
                    }
                case .Error(let error):
                    print(error)
                    
                    var contractAbi: String
                    if contractAddress.address == "0xfa28ec7198028438514b49a3cf353bca5541ce1d" {
                        contractAbi = peepEthAbi
                    } else {
                        contractAbi = peepEthAbi
                    }
                    self.transactionsService.prepareTransactionToContract(data: parsed.parameters.map{return $0.value}, contractAbi: contractAbi, contractAddress: contractAddress.address, method: methodName, amountString: "0") { (result) in
                        switch result {
                        case .Error(let error):
                            print(error)
                        case .Success(let intermediate):
                            let controller = SendArbitraryTransactionViewController(params: params, transactionInfo: TransactionInfo(contractAddress: contractAddress.address, transactionIntermediate: intermediate, methodName: methodName))
                            window.rootViewController = controller
                            window.makeKeyAndVisible()
                        }
                    }
                }
            }
            
        case true:
            print("TODO")
        }
    }
}

