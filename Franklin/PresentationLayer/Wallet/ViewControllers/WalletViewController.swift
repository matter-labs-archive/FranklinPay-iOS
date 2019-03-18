//
//  WalletViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress
import BigInt
import QRCodeReader
import secp256k1_swift
import SideMenu

class WalletViewController: BasicViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var walletTableView: BasicTableView!
    @IBOutlet weak var sendMoneyButton: BasicBlueButton!
    @IBOutlet weak var scanQrButton: ScanButton!
    @IBOutlet weak var marker: UIImageView!
    
    // MARK: - Internal lets
    
    internal let userKeys = UserDefaultKeys()
    internal var tokensService = TokensService()
    internal var walletsService = WalletsService()
    internal var tokensArray: [TableToken] = []
    
    internal let walletSections: [WalletSections] = [.card, .tokens]

    internal let alerts = Alerts()
    internal let etherCoordinator = EtherCoordinator()
    
    internal var stopUpdatingTable = false
    
    internal let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)

    // MARK: - Lazy vars
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
        #selector(handleRefresh(_:)),
                for: UIControl.Event.valueChanged)
        refreshControl.tintColor = Colors.mainBlue

        return refreshControl
    }()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }

        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Lifesycle

    override func viewDidLoad() {
        super.viewDidLoad()
        mainSetup()
        setupNavigation()
        setupTableView()
        additionalSetup()
        setupSideBar()
        additionalSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMarker()
        appearAnimation()
        switch CurrentNetwork.currentNetwork.id {
        case 100:
            setXDai()
        default:
            setTokensList()
        }
    }
    
    // MARK: - Main setup
    
    func mainSetup() {
        parent?.view.backgroundColor = .white
        view.alpha = 0
        view.backgroundColor = Colors.background
        tabBarController?.view.addSubview(topViewForModalAnimation)
        sendMoneyButton.setTitle("Send money", for: .normal)
    }
    
    func setupMarker() {
        marker.isUserInteractionEnabled = false
        guard let wallet = CurrentWallet.currentWallet else {
            return
        }
        if userKeys.isBackupReady(for: wallet) {
            marker.alpha = 0
        } else {
            marker.alpha = 1
        }
    }
    
    func additionalSetup() {
        topViewForModalAnimation.blurView()
        topViewForModalAnimation.alpha = 0
        topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        topViewForModalAnimation.isUserInteractionEnabled = false
    }
    
    func setupSideBar() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SettingsViewController())
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: view)
        
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuWidth = Constants.SideMenu.widthCoeff * UIScreen.main.bounds.width
        SideMenuManager.default.menuShadowOpacity = Constants.SideMenu.shadowOpacity
        SideMenuManager.default.menuShadowColor = UIColor.black
        SideMenuManager.default.menuShadowRadius = Constants.SideMenu.shadowRadius
    }

    func setupTableView() {
        let nibCard = UINib.init(nibName: "CardCell", bundle: nil)
        let nibToken = UINib.init(nibName: "TokenCell", bundle: nil)
        walletTableView.delegate = self
        walletTableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        walletTableView.tableFooterView = footerView
        walletTableView.addSubview(refreshControl)
        walletTableView.register(nibToken, forCellReuseIdentifier: "TokenCell")
        walletTableView.register(nibCard, forCellReuseIdentifier: "CardCell")
    }
    
    func appearAnimation() {
        UIView.animate(withDuration: Constants.ModalView.animationDuration) { [unowned self] in
            self.view.alpha = 1
        }
    }

    func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Table view setup and updates

    func clearData() {
        tokensArray.removeAll()
    }
    
    func setXDai() {
        DispatchQueue.global().async { [unowned self] in
            let tokens = self.etherCoordinator.getTokens()
            if self.stopUpdatingTable {
                self.stopUpdatingTable = false
                return
            }
            self.reloadTokensInTable(tokens: tokens, completion: { [unowned self] in
                self.updateTokensBalances(tokens: tokens) { [unowned self] uTokens in
                    self.saveTokensBalances(tokens: uTokens)
                    if self.stopUpdatingTable {
                        self.stopUpdatingTable = false
                        self.refreshControl.endRefreshing()
                        return
                    }
                    self.reloadBalancesInTable(forTokens: uTokens, completion: {
                        self.refreshControl.endRefreshing()
                        print("Updated")
                    })
                }
            })
        }
    }
    
//    func removeDeletedTokens(forTokens oldTokens: [TableToken]) -> [TableToken] {
//        var fixedTokens = oldTokens
//        var newTokens = self.tokensArray
//        for i in 0..<tokensArray.count {
//            if oldTokens[i].token != newTokens[i].token {
//                fixedTokens.remove(at: i)
//                fixedTokens = removeDeletedTokens(forTokens: fixedTokens)
//                break
//            }
//        }
//        return fixedTokens
//    }
    
    func setTokensList() {
        DispatchQueue.global().asyncAfter(deadline: .now()+0.1) { [unowned self] in
            let tokens = self.etherCoordinator.getTokens()
            if self.stopUpdatingTable {
                self.stopUpdatingTable = false
                return
            }
            self.reloadTokensInTable(tokens: tokens, completion: { [unowned self] in
                self.updateTokensBalances(tokens: tokens) { [unowned self] uTokens in
                    self.saveTokensBalances(tokens: uTokens)
                    if self.stopUpdatingTable {
                        self.stopUpdatingTable = false
                        self.refreshControl.endRefreshing()
                        return
                    }
                    self.reloadBalancesInTable(forTokens: uTokens, completion: {
                        self.refreshControl.endRefreshing()
                        print("Updated")
                    })
                }
            })
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.updateTokensBalances(tokens: tokensArray) { [unowned self] uTokens in
            self.saveTokensBalances(tokens: uTokens)
            if self.stopUpdatingTable {
                self.stopUpdatingTable = false
                self.refreshControl.endRefreshing()
                return
            }
            self.reloadBalancesInTable(forTokens: uTokens, completion: {
                self.refreshControl.endRefreshing()
                print("Updated")
            })
        }
    }
    
    func reloadTableView(completion: @escaping () -> Void) {
        DispatchQueue.main.async { [unowned self] in
            self.walletTableView.reloadData()
            completion()
        }
    }

    func reloadTokensInTable(tokens: [TableToken], completion: @escaping () -> Void) {
        tokensArray = tokens
        reloadTableView {
            completion()
        }
    }
    
    func reloadBalancesInTable(forTokens tokens: [TableToken], completion: @escaping () -> Void) {
        for token in tokens {
            for tokenInTable in tokensArray where token.token == tokenInTable.token {
                tokenInTable.token.balance = token.token.balance
            }
        }
        reloadTableView {
            completion()
        }
    }

    func updateTokenRow(rowIndexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            self.walletTableView.reloadRows(at: [rowIndexPath], with: .none)
        }
    }
    
    // MARK: - Balances

    func updateTokensBalances(tokens: [TableToken], completion: @escaping ([TableToken]) -> Void) {
        DispatchQueue.global().async { [unowned self] in
//            var index = 0
            var newTokens = [TableToken]()
            var xdaiTokens: [ERC20Token] = []
            if CurrentNetwork.currentNetwork.isXDai() {
                if let wallet = tokens.first?.inWallet {
                    if let ts = try? wallet.getXDAITokens() {
                        xdaiTokens = ts
                    }
                }
            }
            for tabToken in tokens {
                var currentTableToken = tabToken
                let currentToken = tabToken.token
                let currentWallet = tabToken.inWallet
                var balance: String
                if CurrentNetwork.currentNetwork.isXDai() && currentToken.isXDai() {
                    balance = "0.0"
                    if let xdaiBalance = try? currentWallet.getXDAIBalance() {
                        balance = xdaiBalance
                    }
                } else if !CurrentNetwork.currentNetwork.isXDai() || (currentToken.isEther() || currentToken.isDai()) {
                    balance = self.etherCoordinator.getBalance(for: currentToken, wallet: currentWallet)
                } else if CurrentNetwork.currentNetwork.isXDai() {
                    balance = "0.0"
                    for xdaiToken in xdaiTokens where xdaiToken == currentToken {
                        if let xBalance = xdaiToken.balance {
                            if let bn = BigUInt(xBalance) {
                                balance = bn.getConvinientRepresentationBalance
                            }
                        }
                    }
                } else {
                    continue
                }
                currentToken.balance = balance
                currentTableToken.token = currentToken
                newTokens.append(currentTableToken)
            }
            completion(newTokens)
        }
    }
    
    func saveTokensBalances(tokens: [TableToken]) {
        for tabToken in tokens {
            let currentToken = tabToken.token
            let currentWallet = tabToken.inWallet
            let currentNetwork = CurrentNetwork.currentNetwork
            if let balance = currentToken.balance {
                try? currentToken.saveBalance(in: currentWallet, network: currentNetwork, balance: balance)
            }
        }
    }
    
    // MARK: - Buttons actions
    
    @IBAction func writeCheque(_ sender: UIButton) {
        let token = tokensArray[0].token
        showSend(token: token)
    }
    
    @IBAction func showMenu(_ sender: Any) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @IBAction func qrScanTapped(_ sender: Any) {
        readerVC.delegate = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
        }
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
//    func showWithdraw() {
//        let alert = UIAlertController(title: "Withdraw to \(CurrentNetwork.currentNetwork.name)", message: nil, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Enter amount"
//            textField.keyboardType = .decimalPad
//        }
//
//        let enterAction = UIAlertAction(title: "Apply", style: .default) { [unowned self] (_) in
//            guard let wallet = CurrentWallet.currentWallet else {
//                showAlert(error: "Cant get wallet")
//                return
//            }
//            DispatchQueue.global().async {
//                do {
//                    print(CurrentNetwork.currentNetwork.name)
//                    let password = try wallet.getPassword()
//                    let maxIteractions = BigUInt(1)
//                    let tx = try wallet.prepareWriteContractTx(contractABI: ignisABI, contractAddress: ignisAddress, contractMethod: "withdrawUserBalance", value: "0", gasLimit: .automatic, gasPrice: .automatic, parameters: [maxIteractions] as [AnyObject], extraData: Data())
//                    let result = try wallet.sendTx(transaction: tx, options: nil, password: password)
//                    print(result.transaction.gasLimit)
//                    print(result.transaction.gasPrice)
//                    print(result.transaction.hash?.toHexString())
//                } catch let error {
//                    showAlert(error: error.localizedDescription)
//                }
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//
//        }
//
//        alert.addAction(enterAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    func showBuy(token: ERC20Token) {
//        let alert = UIAlertController(title: "Buy \(token.name)", message: nil, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Enter amount in ETH"
//            textField.keyboardType = .decimalPad
//        }
//
//        let enterAction = UIAlertAction(title: "Apply", style: .default) { [unowned self] (_) in
//            guard let wallet = CurrentWallet.currentWallet else {
//                showAlert(error: "Cant get wallet")
//                return
//            }
//            guard let amount = alert.textFields![0].text else {
//                showAlert(error: "Cant get amount")
//                return
//            }
//            guard Float(amount)! > 0 else {
//                showAlert(error: "Can't be zero")
//                return
//            }
//            DispatchQueue.global().async {
//                do {
//                    print(CurrentNetwork.currentNetwork.name)
//                    let timestamp = BigUInt(Date().timestamp+300)
//                    let minTokens = BigUInt(1)
//                    let web3 = CurrentNetwork().isXDai() ? Web3.InfuraMainnetWeb3() : nil
//
//                    let password = try wallet.getPassword()
//                    let tx = try wallet.prepareWriteContractTx(web3instance: web3, contractABI: ABIs.uniswap, contractAddress: Addresses.uniswapDai, contractMethod: "ethToTokenSwapInput", value: amount, gasLimit: .automatic, gasPrice: .automatic, parameters: [minTokens, timestamp] as [AnyObject], extraData: Data())
//                    let result = try wallet.sendTx(transaction: tx, options: nil, password: password)
//                    print(result.transaction.gasLimit)
//                    print(result.transaction.gasPrice)
//                    print(result.transaction.hash?.toHexString())
//                } catch let error {
//                    showAlert(error: error.localizedDescription)
//                }
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//
//        }
//
//        alert.addAction(enterAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    func showSell(token: ERC20Token) {
//        let alert = UIAlertController(title: "Sell \(token.name)", message: nil, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Enter amount in \(token.symbol.uppercased())"
//            textField.keyboardType = .decimalPad
//        }
//
//        let enterAction = UIAlertAction(title: "Apply", style: .default) { [unowned self] (_) in
//            guard let wallet = CurrentWallet.currentWallet else {
//                showAlert(error: "Cant get wallet")
//                return
//            }
//            guard let amount = alert.textFields![0].text else {
//                showAlert(error: "Cant get amount")
//                return
//            }
//            guard Float(amount)! > 0 else {
//                showAlert(error: "Can't be zero")
//                return
//            }
//            DispatchQueue.global().async {
//                do {
//                    print(CurrentNetwork.currentNetwork.name)
//                    let timestamp = BigUInt(Date().timestamp+300)
//                    let minEth = BigUInt(1)
//                    let tokens = Web3.Utils.parseToBigUInt(amount, units: .eth)
//                    let web3 = CurrentNetwork().isXDai() ? Web3.InfuraMainnetWeb3() : nil
//
//                    let password = try wallet.getPassword()
//                    let tx = try wallet.prepareWriteContractTx(web3instance: web3, contractABI: ABIs.uniswap, contractAddress: Addresses.uniswapDai, contractMethod: "tokenToEthSwapInput", value: "0.0", gasLimit: .automatic, gasPrice: .automatic, parameters: [tokens, minEth, timestamp] as [AnyObject], extraData: Data())
//                    let result = try wallet.sendTx(transaction: tx, options: nil, password: password)
//                    print(result.transaction.gasLimit)
//                    print(result.transaction.gasPrice)
//                    print(result.transaction.hash?.toHexString())
//                } catch let error {
//                    showAlert(error: error.localizedDescription)
//                }
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//
//        }
//
//        alert.addAction(enterAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    func showConvertToXDai(token: ERC20Token) {
//        let alert = UIAlertController(title: "Convert to xDai", message: nil, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Enter amount in \(token.symbol.uppercased())"
//            textField.keyboardType = .decimalPad
//        }
//
//        let enterAction = UIAlertAction(title: "Apply", style: .default) { [unowned self] (_) in
//            guard let wallet = CurrentWallet.currentWallet else {
//                showAlert(error: "Cant get wallet")
//                return
//            }
//            guard let amount = alert.textFields![0].text else {
//                showAlert(error: "Cant get amount")
//                return
//            }
//            guard Float(amount)! > 0 else {
//                showAlert(error: "Can't be zero")
//                return
//            }
//            DispatchQueue.global().async {
//                do {
//                    print(CurrentNetwork.currentNetwork.name)
//                    let xdaiContract = EthereumAddress(Addresses.daiToXDai)!
//                    let tokens = Web3.Utils.parseToBigUInt(amount, units: .eth)
//                    let web3 = CurrentNetwork().isXDai() ? Web3.InfuraMainnetWeb3() : nil
//
//                    let password = try wallet.getPassword()
//                    let tx = try wallet.prepareWriteContractTx(web3instance: web3, contractABI: ABIs.dai, contractAddress: Addresses.dai, contractMethod: "transfer", value: "0.0", gasLimit: .automatic, gasPrice: .automatic, parameters: [xdaiContract, tokens] as [AnyObject], extraData: Data())
//                    let result = try wallet.sendTx(transaction: tx, options: nil, password: password)
//                    print(result.transaction.gasLimit)
//                    print(result.transaction.gasPrice)
//                    print(result.transaction.hash?.toHexString())
//                } catch let error {
//                    showAlert(error: error.localizedDescription)
//                }
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//
//        }
//
//        alert.addAction(enterAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    func showConvertToDai(token: ERC20Token) {
//        let alert = UIAlertController(title: "Convert to Dai", message: nil, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Enter amount in \(token.symbol.uppercased())"
//            textField.keyboardType = .decimalPad
//        }
//
//        let enterAction = UIAlertAction(title: "Apply", style: .default) { [unowned self] (_) in
//            guard let wallet = CurrentWallet.currentWallet else {
//                showAlert(error: "Cant get wallet")
//                return
//            }
//            guard let amount = alert.textFields![0].text else {
//                showAlert(error: "Cant get amount")
//                return
//            }
//            guard Float(amount)! > 0 else {
//                showAlert(error: "Can't be zero")
//                return
//            }
//            DispatchQueue.global().async {
//                do {
//                    print(CurrentNetwork.currentNetwork.name)
//                    let password = try wallet.getPassword()
//                    let tx = try wallet.prepareSendXDaiTx(toAddress: Addresses.xDaiToDai, value: amount)
//                    let result = try wallet.sendTx(transaction: tx, options: nil, password: password)
//                    print(result.transaction.gasLimit)
//                    print(result.transaction.gasPrice)
//                    print(result.transaction.hash?.toHexString())
//                } catch let error {
//                    showAlert(error: error.localizedDescription)
//                }
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//
//        }
//
//        alert.addAction(enterAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    func showConvertToBuff(token: ERC20Token) {
//        let alert = UIAlertController(title: "Convert to Buff", message: nil, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Enter amount in $"
//            textField.keyboardType = .decimalPad
//        }
//
//        let enterAction = UIAlertAction(title: "Apply", style: .default) { [unowned self] (_) in
//            guard let wallet = CurrentWallet.currentWallet else {
//                showAlert(error: "Cant get wallet")
//                return
//            }
//            guard let amount = alert.textFields![0].text else {
//                showAlert(error: "Cant get amount")
//                return
//            }
//            guard Float(amount)! > 0 else {
//                showAlert(error: "Can't be zero")
//                return
//            }
//            DispatchQueue.global().async {
//                do {
//                    print(CurrentNetwork.currentNetwork.name)
//                    let password = try wallet.getPassword()
//                    let tx = try wallet.prepareWriteContractTx(web3instance: nil, contractABI: ABIs.buffVending, contractAddress: Addresses.buffVending, contractMethod: "deposit", value: amount, gasLimit: .automatic, gasPrice: .automatic, parameters: [], extraData: Data())
//                    let result = try wallet.sendTx(transaction: tx, password: password)
//                    print(result.transaction.gasLimit)
//                    print(result.transaction.gasPrice)
//                    print(result.transaction.hash?.toHexString())
//                } catch let error {
//                    showAlert(error: error.localizedDescription)
//                }
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//
//        }
//
//        alert.addAction(enterAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
//
//    func showDeposit() {
//        let alert = UIAlertController(title: "Deposit to Franklin", message: nil, preferredStyle: UIAlertController.Style.alert)
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Enter amount"
//            textField.keyboardType = .decimalPad
//        }
//
//        let enterAction = UIAlertAction(title: "Apply", style: .default) { [unowned self] (_) in
//            guard let wallet = CurrentWallet.currentWallet else {
//                showAlert(error: "Cant get wallet")
//                return
//            }
//            guard let amount = alert.textFields![0].text else {
//                showAlert(error: "Cant get amount")
//                return
//            }
//            guard Float(amount)! > 0 else {
//                showAlert(error: "Can't be zero")
//                return
//            }
//            DispatchQueue.global().async {
//                do {
//                    print(CurrentNetwork.currentNetwork.name)
//                    let password = try wallet.getPassword()
//                    let pk = try wallet.getPrivateKey(withPassword: password)
//                    let dataPK = Data(hex: pk)
//                    guard let publicKey = SECP256K1.privateToPublic(privateKey: dataPK) else {
//                        showAlert(error: "Cant get public key")
//                        return
//                    }
//                    var stringPublicKey = publicKey.toHexString()
//                    stringPublicKey.removeFirst(2)
//                    let count = stringPublicKey.count
//                    let x = String(stringPublicKey.prefix(count/2))
//                    let y = String(stringPublicKey.suffix(count/2))
//                    guard let bnY = BigUInt(y, radix: 16) else {
//                        showAlert(error: "Cant get public key y")
//                        return
//                    }
//                    guard let bnX = BigUInt(x, radix: 16) else {
//                        showAlert(error: "Cant get public key x")
//                        return
//                    }
//                    let fee = BigUInt(0)
//                    let tx = try wallet.prepareWriteContractTx(contractABI: ignisABI, contractAddress: ignisAddress, contractMethod: "deposit", value: amount, gasLimit: .automatic, gasPrice: .automatic, parameters: [[bnX, bnY], fee] as [AnyObject], extraData: Data())
//                    let result = try wallet.sendTx(transaction: tx, options: nil, password: password)
//                    print(result.transaction.gasLimit)
//                    print(result.transaction.gasPrice)
//                    print(result.transaction.hash?.toHexString())
//                } catch let error {
//                    showAlert(error: error.localizedDescription)
//                }
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
//
//        }
//
//        alert.addAction(enterAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
//    }
    
//    func showCardAlert(token: ERC20Token) {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [unowned self] (action) in
//            showSend(token: token)
//        }))
//        if token.isFranklin() {
//            alert.addAction(UIAlertAction(title: "Deposit", style: .default, handler: { [unowned self] (action) in
//                showDeposit()
//            }))
//            alert.addAction(UIAlertAction(title: "Withdraw", style: .default, handler: { [unowned self] (action) in
//                showWithdraw()
//            }))
//        }
//        if token.isXDai() {
//            alert.addAction(UIAlertAction(title: "Dai to xDai", style: .default, handler: { [unowned self] (action) in
//                showConvertToXDai(token: Dai())
//            }))
//            alert.addAction(UIAlertAction(title: "xDai to Dai", style: .default, handler: { [unowned self] (action) in
//                showConvertToDai(token: token)
//            }))
//        }
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(alert, animated: true)
//    }
//
//    func showTokenAlert(token: ERC20Token) {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [unowned self] (action) in
//            showSend(token: token)
//        }))
////        if !token.isEther() {
////            alert.addAction(UIAlertAction(title: "Buy by Ether", style: .default, handler: { [unowned self] (action) in
////                showBuy(token: token)
////            }))
//////            alert.addAction(UIAlertAction(title: "Sell for Ether", style: .default, handler: { [unowned self] (action) in
//////                showSell(token: token)
//////            }))
////        }
//        if token.isDai() {
//            alert.addAction(UIAlertAction(title: "Buy by Ether", style: .default, handler: { [unowned self] (action) in
//                showBuy(token: token)
//            }))
//            alert.addAction(UIAlertAction(title: "Convert to xDai", style: .default, handler: { [unowned self] (action) in
//                showConvertToXDai(token: token)
//            }))
//        }
//
//        if token.isBuff() {
//            alert.addAction(UIAlertAction(title: "xDai to Buff", style: .default, handler: { [unowned self] (action) in
//                showConvertToBuff(token: token)
//            }))
//        }
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(alert, animated: true)
//    }
    
}
