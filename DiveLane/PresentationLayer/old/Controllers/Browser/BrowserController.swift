////
////  BrowserController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 03/12/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import Foundation
//import UIKit
//import WebKit
//import Web3swift
//import WKBridge
//import EthereumAddress
//
//class BrowserController: UIViewController {
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setNavigation()
//        self.navigationItem.setRightBarButton(settingsWalletBarItem(), animated: false)
//    }
//    
//    private func settingsWalletBarItem() -> UIBarButtonItem {
//        let addButton = UIBarButtonItem(image: UIImage(named: "settings_blue"),
//                                        style: .plain,
//                                        target: self,
//                                        action: #selector(settingsWallet))
//        return addButton
//    }
//    
//    @objc func settingsWallet() {
//        //let walletsViewController = WalletsViewController()
//        let settingsViewController = SettingsViewController()
//        self.navigationController?.pushViewController(settingsViewController, animated: true)
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        keyboardExtensions()
//    }
//    
//    func keyboardExtensions() {
//        self.hideKeyboardWhenTappedAround()
//    }
//    
//    func setNavigation() {
//        self.title = "Browser"
//    }
//
//    enum Method: String {
//        case getAccounts
//        case signTransaction
//        case signMessage
//        case signPersonalMessage
//        case publishTransaction
//        case approveTransaction
//    }
//    
//    lazy var webView: WKWebView = {
//        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
//        let date = NSDate(timeIntervalSince1970: 0)
//        
//        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler: { })
//        let webView = WKWebView(
//            frame: .zero,
//            configuration: self.config
//        )
//        webView.allowsBackForwardNavigationGestures = true
//        webView.scrollView.isScrollEnabled = true
//        webView.navigationDelegate = self
//        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
//        return webView
//    }()
//    
//    lazy var config: WKWebViewConfiguration = {
//        let config = WKWebViewConfiguration()
//        
//        var js = ""
//        
//        if let filepath = Bundle.main.path(forResource: "Web3Swift.min", ofType: "js") {
//            do {
//                js += try String(contentsOfFile: filepath)
//                NSLog("Loaded web3swift.js")
//            } catch {
//                NSLog("Failed to load web.js")
//            }
//        } else {
//            NSLog("web3.js not found in bundle")
//        }
//        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
//        config.userContentController.addUserScript(userScript)
//        return config
//    }()
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(webView)
//        
//        NSLayoutConstraint.activate([
//            webView.topAnchor.constraint(equalTo: view.topAnchor),
//            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            ])
//        
//        //webView.load(URLRequest(url: URL(string: "https://peepeth.com/")!))
//        //webView.load(URLRequest(url: URL(string: "https://plasma-testnet.thematter.io/")!))
//        webView.load(URLRequest(url: URL(string: "https://peepeth.com/")!))
//        
//        do {
//            let wallet = try WalletsService().getSelectedWallet()
//            let senderString = wallet.address
//            guard let sender = EthereumAddress(senderString) else {return}
//            print(sender)
//            let web3 = Web3Service().web3Instance
//            
//            self.webView.bridge.register({ (_, completion) in
//                let url = web3.provider.url.absoluteString
//                completion(.success(["rpcURL": url as Any]))
//            }, for: "getRPCurl")
//            
//            self.webView.bridge.register({ (_, completion) in
//                guard let allAccounts = try? WalletsService().getAllWallets().compactMap({$0.address}) else {
//                    return
//                }
//                completion(.success(["accounts": allAccounts as Any]))
//            }, for: "eth_getAccounts")
//            
//            self.webView.bridge.register({ (_, completion) in
//                let coinbase = web3.browserFunctions.getCoinbase()
//                completion(.success(["coinbase": coinbase as Any]))
//            }, for: "eth_coinbase")
//            self.webView.bridge.register({ (parameters, completion) in
//                if parameters == nil {
//                    completion(.failure(Bridge.JSError(code: 0, description: "No parameters provided")))
//                    return
//                }
//                let payload = parameters!["payload"] as? [String:Any]
//                if payload == nil {
//                    completion(.failure(Bridge.JSError(code: 0, description: "No parameters provided")))
//                    return
//                }
//                let personalMessage = payload!["data"] as? String
//                let account = payload!["from"] as? String
//                if personalMessage == nil || account == nil {
//                    completion(.failure(Bridge.JSError(code: 0, description: "Not enough parameters provided")))
//                    return
//                }
//                let result = web3.browserFunctions.personalSign(personalMessage!, account: account!)
//                if result == nil {
//                    completion(.failure(Bridge.JSError(code: 0, description: "Account or data is invalid")))
//                    return
//                }
//                completion(.success(["signedMessage": result as Any]))
//            }, for: "eth_sign")
//            self.webView.bridge.register({ (parameters, completion) in
//                if parameters == nil {
//                    completion(.failure(Bridge.JSError(code: 0, description: "No parameters provided")))
//                    return
//                }
//                let transaction = parameters!["transaction"] as? [String:Any]
//                if transaction == nil {
//                    completion(.failure(Bridge.JSError(code: 0, description: "Not enough parameters provided")))
//                    return
//                }
//                let result = web3.browserFunctions.signTransaction(transaction!)
//                if result == nil {
//                    completion(.failure(Bridge.JSError(code: 0, description: "Data is invalid")))
//                    return
//                }
//                completion(.success(["signedTransaction": result as Any]))
//            }, for: "eth_signTransaction")
//        } catch {
//            print(error)
//        }
//    }
//
//}
//
//extension BrowserController: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        
//    }
//}
//
//extension BrowserController: WKScriptMessageHandler {
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        NSLog("message \(message.body)")
//    }
//}
