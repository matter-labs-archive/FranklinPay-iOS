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

let peepEthAbi = """
[ { "constant": false, "inputs": [ { "name": "_followee", "type": "address" } ], "name": "unFollow", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "updateAccount", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "isActive", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_isActive", "type": "bool" } ], "name": "setIsActive", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_followee", "type": "address" } ], "name": "follow", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_name", "type": "bytes16" } ], "name": "changeName", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "address" } ], "name": "names", "outputs": [ { "name": "", "type": "bytes32" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "reply", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "bytes32" } ], "name": "addresses", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_address", "type": "address" } ], "name": "setNewAddress", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [ { "name": "_addr", "type": "address" } ], "name": "accountExists", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [ { "name": "bStr", "type": "bytes16" } ], "name": "isValidName", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "pure", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "share", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "saveBatch", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [], "name": "cashout", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "owner", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "post", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_name", "type": "bytes16" }, { "name": "_ipfsHash", "type": "string" } ], "name": "createAccount", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "newMinPercentage", "type": "uint256" } ], "name": "setMinSiteTipPercentage", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "_author", "type": "address" }, { "name": "_messageID", "type": "string" }, { "name": "_ownerTip", "type": "uint256" }, { "name": "_ipfsHash", "type": "string" } ], "name": "tip", "outputs": [], "payable": true, "stateMutability": "payable", "type": "function" }, { "constant": true, "inputs": [], "name": "newAddress", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [ { "name": "", "type": "uint256" } ], "name": "interfaceInstances", "outputs": [ { "name": "interfaceAddress", "type": "address" }, { "name": "startBlock", "type": "uint96" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "_address", "type": "address" } ], "name": "transferAccount", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [], "name": "lockMinSiteTipPercentage", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "interfaceInstanceCount", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "minSiteTipPercentage", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [ { "name": "newOwner", "type": "address" } ], "name": "transferOwnership", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "tipPercentageLocked", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor" }, { "payable": true, "stateMutability": "payable", "type": "fallback" }, { "anonymous": false, "inputs": [], "name": "PeepethEvent", "type": "event" } ]
"""
class AppController {
    
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
                                        withImage: UIImage(named: "user"),
                                        withController: WalletViewController(nibName: nil, bundle: nil),
                                        tag: 1)
        
        let nav2 = navigationController(withTitle: "Settings",
                                        withImage: UIImage(named:"settings"),
                                        withController: SettingsViewController(nibName: nil, bundle: nil),
                                        tag: 2)
        
        let nav3 = navigationController(withTitle: "Transactions History",
                                        withImage: UIImage(named:"history"),
                                        withController: TransactionsHistoryViewController(),
                                        tag: 3)
        
        let nav4 = navigationController(withTitle: "Send",
                                        withImage: UIImage(named:"send"),
                                        withController: SendSettingsViewController(),
                                        tag: 4)
        
        tabs.viewControllers = [nav1, nav3, nav2, nav4]
        
        return tabs
    }
    
    func navigationController(withTitle: String?, withImage: UIImage?, withController: UIViewController, tag: Int) -> UINavigationController {
        let nav = UINavigationController()
        nav.navigationBar.barTintColor = Colors().mainNavigationBarTintColor
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
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
        let existingWallet = LocalDatabase().getWallet()
        
        if !isOnboardingPassed {
            startViewController = OnboardingViewController()
            startViewController?.view.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1)
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
                    guard let wallet = KeysService().selectedWallet() else {return}
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
    
    func selectWallet(completion: @escaping (KeyWalletModel?)->()) {
        guard let firstWallet = LocalDatabase().getWallet() else {
            completion(nil)
            return
        }
        completion(firstWallet)
        
    }
    
    func selectToken(for wallet: KeyWalletModel) {
        LocalDatabase().selectWallet(wallet: wallet) {
            let token = LocalDatabase().getAllTokens(for: wallet, forNetwork: Int64(CurrentNetwork.currentNetwork?.chainID ?? 1)).first
            CurrentToken.currentToken = token
        }
    }
    
    func addFirstToken(for wallet: KeyWalletModel, completion: @escaping (Error?) -> Void) {
        let currentNetworkID = Int64(String(CurrentNetwork.currentNetwork?.chainID ?? 0)) ?? 0
        for networkID in 1...42 {
            let etherToken = ERC20TokenModel(isEther: true)
            LocalDatabase().saveCustomToken(with: etherToken, forWallet: wallet, forNetwork: Int64(networkID)) { (error) in
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
//        let fun = ABIv2.Element.function(parsed.function!)
//        let data = fun.encodeParameters(parsed.parameters.compactMap{return $0.value})
//        print(    data?.toHexString())
        switch parsed.isPayRequest {
            //Custom transaction
        case false:
            if parsed.functionName == "transfer" {
                
                let tokenAddress = parsed.function?.inputs[0].name
                guard let amount = parsed.function?.inputs[1].name else { return }
                guard case .ethereumAddress(let targetAddress) = parsed.targetAddress else { return }
                let controller = SendSettingsViewController(tokenAddress: tokenAddress, amount: BigUInt(amount)!, destinationAddress: targetAddress.address, isFromDeepLink: true)
                window.rootViewController = controller
                window.makeKeyAndVisible()
            } else {
                //MARK: - Choose the right network, MAINNET by default, if no network provided.
                switch parsed.chainID {
                case 1?:
                    CurrentNetwork.currentNetwork = Networks.Mainnet
                case 3?:
                    CurrentNetwork.currentNetwork = Networks.Ropsten
                case 4?:
                    CurrentNetwork.currentNetwork = Networks.Rinkeby
                case 42?:
                    CurrentNetwork.currentNetwork = Networks.Kovan
                case .some(let value):
                    CurrentNetwork.currentNetwork = Networks.Custom(networkID: value)
                default:
                    CurrentNetwork.currentNetwork = Networks.Mainnet
                }
                let web3 = web3swift.web3(provider: InfuraProvider(CurrentNetwork.currentNetwork ?? Networks.Mainnet)!)
                CurrentWeb.currentWeb = web3
                
                //Preparing the options
                var options: Web3Options = Web3Options.defaultOptions()
                options.gasLimit = parsed.gasLimit
                options.gasPrice = parsed.gasPrice
                options.value = parsed.amount
                //TODO: - ENS parser
                guard case .ethereumAddress(let contractAddress) = parsed.targetAddress else { return }
                guard let methodName = parsed.functionName else { return }
                guard let params = parsed.function?.inputs.map({return Parameter(type: $0.type.abiRepresentation, value: $0.name)}) else { return }
                //let params = parsed.params.map { return Parameter(type: $0.0, value: $0.1) }
                etherscanService.getAbi(forContractAddress: contractAddress.address) { (result) in
                    switch result {
                    case .Success(let abi):
                        self.transactionsService.prepareTransactionToContract(data: parsed.parameters.map{ return $0.value }, contractAbi: abi, contractAddress: contractAddress.address, method: methodName, predefinedOptions: options) { (result) in
                            switch result {
                            case .Error(let error):
                                print(error)
                                let controller = self.goToApp()
                                window.rootViewController = controller
                                window.makeKeyAndVisible()
                                showErrorAlert(for: controller, error: error, completion: {
                                    
                                })
                            case .Success(let intermediate):
                                let controller = SendArbitraryTransactionViewController(params: params, transactionInfo: TransactionInfo(contractAddress: contractAddress.address, transactionIntermediate: intermediate, methodName: methodName))
                                window.rootViewController = controller
                                window.makeKeyAndVisible()
                            }
                        }
                    case .Error(let error):
                        print(error)
                        //If there is no ABI posted on etherscan.
                        var contractAbi: String
                        if contractAddress.address == "0xfa28ec7198028438514b49a3cf353bca5541ce1d" {
                            contractAbi = peepEthAbi
                        } else {
                            contractAbi = peepEthAbi
                        }
                        self.transactionsService.prepareTransactionToContract(data: parsed.parameters.map{return $0.value}, contractAbi: contractAbi, contractAddress: contractAddress.address, method: methodName, predefinedOptions: options) { (result) in
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
            }
            
            //Regular sending of ETH
        case true:
            guard case .ethereumAddress(let targetAddress) = parsed.targetAddress else { return }
            let controller = SendSettingsViewController(tokenAddress: "", amount: parsed.amount ?? 0, destinationAddress: targetAddress.address, isFromDeepLink: true)
            window.rootViewController = controller
            window.makeKeyAndVisible()
            
//            self.transactionsService.prepareTransactionForSendingEther(destinationAddressString: targetAddress.address, amountString: String(parsed.amount ?? 0), gasLimit: 21000, completion: { (result) in
//                switch result {
//                case .Error(let error):
//                    print(error)
//                case .Success(let intermediate):
//                    let controller = SendArbitraryTransactionViewController(params: params, transactionInfo: TransactionInfo(contractAddress: targetAddress.address, transactionIntermediate: intermediate, methodName: methodName ?? "transfer"))
//                    window.rootViewController = controller
//                    window.makeKeyAndVisible()
//                }
//            })
        }
    }
}

