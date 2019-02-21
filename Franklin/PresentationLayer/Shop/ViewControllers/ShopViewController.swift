////
////  WalletViewController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 08/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//import Web3swift
//import EthereumAddress
//import BigInt
//import SideMenu
//import QRCodeReader
//import secp256k1_swift
//
//enum ShopSections: Int {
//    case card = 0
//}
//
//class ShopViewController: BasicViewController, ModalViewDelegate {
//
//    @IBOutlet weak var walletTableView: BasicTableView!
//    @IBOutlet weak var sendMoneyButton: BasicBlueButton!
//    @IBOutlet weak var scanQrButton: ScanButton!
//    @IBOutlet weak var marker: UIImageView!
//    
//    private let userKeys = UserDefaultKeys()
//    private var tokensService = TokensService()
//    private var walletsService = WalletsService()
//    private var tokensArray: [TableToken] = []
//    
//    private let shopSections: [WalletSections] = [.card]
//
//    private let alerts = Alerts()
//    private let etherCoordinator = EtherCoordinator()
//    
//    let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
//
//    lazy var refreshControl: UIRefreshControl = {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action:
//        #selector(self.handleRefresh(_:)),
//                for: UIControl.Event.valueChanged)
//        //refreshControl.alpha = 0
//        refreshControl.tintColor = Colors.mainBlue
//
//        return refreshControl
//    }()
//    
//    lazy var readerVC: QRCodeReaderViewController = {
//        let builder = QRCodeReaderViewControllerBuilder {
//            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
//        }
//
//        return QRCodeReaderViewController(builder: builder)
//    }()
//    
//    @IBAction func qrScanTapped(_ sender: Any) {
//        readerVC.delegate = self
//
//        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
//        }
//        readerVC.modalPresentationStyle = .formSheet
//        present(readerVC, animated: true, completion: nil)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.parent?.view.backgroundColor = .white
//        self.view.alpha = 0
//        self.view.backgroundColor = Colors.background
//        self.setupNavigation()
//        self.setupTableView()
//        self.additionalSetup()
//        self.setupSideBar()
//        self.additionalSetup()
//        
////        guard let wallet = CurrentWallet.currentWallet else {return}
////        do {
////            let pv = try wallet.getPassword()
////            let pk = try wallet.getPrivateKey(withPassword: pv)
////            let nonce = try CurrentWallet.currentWallet!.getPlasmaNonce(network: CurrentNetwork.currentNetwork)
////            let transaction = TransactionIgnis()
////            try transaction.createTransaction(from: 150, to: 151, amount: 10, privateKey: pk)
////            print("ho")
////        } catch {
////            return
////        }
//    }
//    
//    func setupMarker() {
//        self.marker.isUserInteractionEnabled = false
//        guard let wallet = CurrentWallet.currentWallet else {
//            return
//        }
//        if userKeys.isBackupReady(for: wallet) {
//            self.marker.alpha = 0
//        } else {
//            self.marker.alpha = 1
//        }
//    }
//    
//    func additionalSetup() {
//        self.sendMoneyButton.setTitle("Pay", for: .normal)
//        self.topViewForModalAnimation.blurView()
//        self.topViewForModalAnimation.alpha = 0
//        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
//        self.topViewForModalAnimation.isUserInteractionEnabled = false
//        self.tabBarController?.view.addSubview(topViewForModalAnimation)
//    }
//    
//    func setupSideBar() {
//        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SettingsViewController())
//        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
//        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
//        
//        SideMenuManager.default.menuFadeStatusBar = false
//        SideMenuManager.default.menuPresentMode = .menuSlideIn
//        SideMenuManager.default.menuWidth = Constants.SideMenu.widthCoeff * UIScreen.main.bounds.width
//        SideMenuManager.default.menuShadowOpacity = Constants.SideMenu.shadowOpacity
//        SideMenuManager.default.menuShadowColor = UIColor.black
//        SideMenuManager.default.menuShadowRadius = Constants.SideMenu.shadowRadius
//    }
//
//    func setupTableView() {
//        let nibCard = UINib.init(nibName: "ShopCell", bundle: nil)
//        self.walletTableView.delegate = self
//        self.walletTableView.dataSource = self
//        let footerView = UIView()
//        footerView.backgroundColor = Colors.background
//        self.walletTableView.tableFooterView = footerView
//        self.walletTableView.addSubview(self.refreshControl)
//        self.walletTableView.register(nibCard, forCellReuseIdentifier: "ShopCell")
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.setupMarker()
//        self.appearAnimation()
//        self.setXDai()
//        
////        print(CurrentWallet.currentWallet?.address)
////        print(try? walletsService.getSelectedWallet().address)
////        guard let wallets = try? walletsService.getAllWallets() else {return}
////        for w in wallets {
////            print(w.address)
////        }
//    }
//    
//    func appearAnimation() {
//        UIView.animate(withDuration: Constants.ModalView.animationDuration) { [unowned self] in
//            self.view.alpha = 1
//        }
//    }
//
//    func setupNavigation() {
//        self.navigationController?.navigationBar.isHidden = true
//    }
//
//    func clearData() {
//        tokensArray.removeAll()
//    }
//    
//    func setXDai() {
//        DispatchQueue.global().async { [unowned self] in
//            let wallet = CurrentWallet.currentWallet!
//            let xdai = self.etherCoordinator.getTokens().first ?? TableToken(token: XDai(), inWallet: wallet, isSelected: true)
//            let tokens = [xdai]
////            if let ercTokens = try? wallet.getXDAITokens() {
////                let tableTokens: [TableToken] = ercTokens.map {
////                    TableToken(token: $0, inWallet: wallet, isSelected: false)
////                }
////                tokens.append(contentsOf: tableTokens)
////            }
//            self.tokensArray = tokens
//            self.reloadDataInTable(completion: { [unowned self] in
//                self.updateTokensBalances(tokens: tokens) { [unowned self] uTokens in
//                    self.saveTokensBalances(tokens: uTokens)
//                    self.tokensArray = uTokens
//                    self.reloadDataInTable {
//                        self.refreshControl.endRefreshing()
//                        print("Updated")
//                    }
//                    //                    self.reloadDataInTable { [unowned self] in
//                    //                        self.saveTokensBalances()
//                    //                        // TODO: - need to update rates?
//                    //                    }
//                }
//            })
//        }
//    }
//    
//    @IBAction func showMenu(_ sender: Any) {
//        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
//    }
//
//    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
//        self.updateTokensBalances(tokens: self.tokensArray) { [unowned self] uTokens in
//            self.saveTokensBalances(tokens: uTokens)
//            self.tokensArray = uTokens
//            self.reloadDataInTable {
//                self.refreshControl.endRefreshing()
//                print("Updated")
//            }
//            //            self.reloadDataInTable { [unowned self] in
//            //                self.refreshControl.endRefreshing()
//            //            }
//        }
//    }
//
//    func reloadDataInTable(completion: @escaping () -> Void) {
//        DispatchQueue.main.async { [unowned self] in
//            self.walletTableView.reloadData()
//            completion()
//        }
//    }
//
//    func updateTokenRow(rowIndexPath: IndexPath) {
//        DispatchQueue.main.async { [unowned self] in
//            self.walletTableView.reloadRows(at: [rowIndexPath], with: .none)
//        }
//    }
//
//    func updateTokensBalances(tokens: [TableToken], completion: @escaping ([TableToken]) -> Void) {
//        DispatchQueue.global().async { [unowned self] in
//            //            var index = 0
//            var newTokens = [TableToken]()
//            var xdaiTokens: [ERC20Token] = []
//            if CurrentNetwork().isXDai() {
//                if let wallet = tokens.first?.inWallet {
//                    if let ts = try? wallet.getXDAITokens() {
//                        xdaiTokens = ts
//                    }
//                }
//            }
//            for tabToken in tokens {
//                var currentTableToken = tabToken
//                let currentToken = tabToken.token
//                let currentWallet = tabToken.inWallet
//                var balance: String
//                if CurrentNetwork().isXDai() && currentToken.isXDai() {
//                    balance = "0.0"
//                    if let xdaiBalance = try? currentWallet.getXDAIBalance() {
//                        if let db = Double(xdaiBalance) {
//                            let rnd = Double(round(1000*db)/1000)
//                            let str = String(rnd)
//                            balance = str
//                        }
//                    }
//                } else if !CurrentNetwork().isXDai() || (currentToken.isEther() || currentToken.isDai()) {
//                    balance = self.etherCoordinator.getBalance(for: currentToken, wallet: currentWallet)
//                } else if CurrentNetwork().isXDai() {
//                    balance = "0.0"
//                    for t in xdaiTokens where t == currentToken {
//                        if let b = t.balance {
//                            if let bn = BigUInt(b) {
//                                var fl = Double(bn)/1000000000000000000
//                                fl = Double(round(1000*fl)/1000)
//                                let str = String(fl)
//                                balance = str
//                            }
//                        }
//                    }
//                } else {
//                    continue
//                }
//                currentToken.balance = balance
//                currentTableToken.token = currentToken
//                newTokens.append(currentTableToken)
//                //                self.tokensArray[index] = currentTableToken
//                //                index += 1
//            }
//            completion(newTokens)
//        }
//    }
//    
//    func saveTokensBalances(tokens: [TableToken]) {
//        for tabToken in tokens {
//            let currentToken = tabToken.token
//            let currentWallet = tabToken.inWallet
//            let currentNetwork = CurrentNetwork.currentNetwork
//            if let balance = currentToken.balance {
//                
//                try? currentToken.saveBalance(in: currentWallet, network: currentNetwork, balance: balance)
//            }
//        }
//    }
//    
//    func modalViewBeenDismissed(updateNeeded: Bool) {
//        DispatchQueue.main.async { [unowned self] in
//            if updateNeeded { self.setXDai() }
//            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
//                self.topViewForModalAnimation.alpha = 0
//            })
//        }
//    }
//    
//    func modalViewAppeared() {
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
//                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
//            })
//        }
//    }
//    
//    @IBAction func writeCheque(_ sender: UIButton) {
//        let token = tokensArray[0].token
//        self.showSend(token: token)
//    }
//    
//    func showSend(token: ERC20Token, address: String) {
//        self.modalViewAppeared()
//        let sendMoneyVC = SendMoneyController(token: token, address: address)
//        sendMoneyVC.delegate = self
//        sendMoneyVC.modalPresentationStyle = .overCurrentContext
//        sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
//        self.tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
//    }
//    
//    func showSend(token: ERC20Token) {
//        self.modalViewAppeared()
//        let sendMoneyVC = SendMoneyController(token: token)
//        sendMoneyVC.delegate = self
//        sendMoneyVC.modalPresentationStyle = .overCurrentContext
//        sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
//        self.tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
//    }
//    
//    func showAlert(error: String? = nil) {
//        DispatchQueue.main.async { [unowned self] in
//            self.alerts.showErrorAlert(for: self, error: error ?? "Unknown error", completion: nil)
//        }
//    }
//    
//    @IBAction func deposit(_ sender: BasicGreenButton) {
//        self.modalViewAppeared()
//        guard let token = self.tokensArray.first?.token else { return }
//        let depositVC = DepositsViewController()
//        depositVC.delegate = self
//        depositVC.modalPresentationStyle = .overCurrentContext
//        depositVC.view.layer.speed = Constants.ModalView.animationSpeed
//        self.tabBarController?.present(depositVC, animated: true, completion: nil)
//    }
//    
//    @IBAction func credit(_ sender: BasicOrangeButton) {
//        self.modalViewAppeared()
//        guard let token = self.tokensArray.first?.token else { return }
//        let creditVC = CreditsViewController(token: token)
//        creditVC.delegate = self
//        creditVC.modalPresentationStyle = .overCurrentContext
//        creditVC.view.layer.speed = Constants.ModalView.animationSpeed
//        self.tabBarController?.present(creditVC, animated: true, completion: nil)
//    }
//    
//}
//
//extension ShopViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return nil
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch indexPath.section {
//        case ShopSections.card.rawValue:
//            return UIScreen.main.bounds.height * Constants.CardCell.heightCoef
//        default:
//            return 0
//        }
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return shopSections.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case ShopSections.card.rawValue:
//            return 1
//        default:
//            return 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if tokensArray.isEmpty {return UITableViewCell()}
//        let card = tokensArray[0]
//        switch indexPath.section {
//        case ShopSections.card.rawValue:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCell",
//                                                           for: indexPath) as? ShopCell else {
//                                                            return UITableViewCell()
//            }
//            let tableToken = card
//            cell.configure(token: tableToken)
//            cell.delegate = self
//            return cell
//        default:
//            return UITableViewCell()
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
//            return
//        }
//        let isCard = indexPath.section == ShopSections.card.rawValue
//        let cell = isCard ?
//            tableView.cellForRow(at: indexPathForSelectedRow) as? ShopCell :
//            tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell
//        guard let selectedCell = cell else {
//            return
//        }
//        guard let indexPathTapped = self.walletTableView.indexPath(for: selectedCell) else {
//            return
//        }
//        let tableToken = isCard ?
//            self.tokensArray[0] :
//            self.tokensArray[indexPathTapped.row+1]
//        
//        self.showSend(token: tableToken.token)
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//}
//
//extension ShopViewController: ShopCellDelegate {
//    func shopInfoTapped(_ sender: ShopCell) {
//        guard let indexPathTapped = self.walletTableView.indexPath(for: sender) else {
//            return
//        }
//        let wallet = self.tokensArray[indexPathTapped.row].inWallet
//        self.modalViewAppeared()
//        let publicKeyController = PublicKeyViewController(for: wallet)
//        publicKeyController.delegate = self
//        publicKeyController.modalPresentationStyle = .overCurrentContext
//        publicKeyController.view.layer.speed = Constants.ModalView.animationSpeed
//        self.tabBarController?.present(publicKeyController, animated: true, completion: nil)
//    }
//}
//
//extension ShopViewController: UISideMenuNavigationControllerDelegate {
//    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
//        modalViewAppeared()
//    }
//    
//    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
//        modalViewBeenDismissed(updateNeeded: false)
//    }
//}
//
//extension ShopViewController: QRCodeReaderViewControllerDelegate {
//    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
//        reader.stopScanning()
//        reader.dismiss(animated: true) { [unowned self] in
//            self.modalViewAppeared()
//            let token = self.tokensArray[0].token
//            self.showSend(token: token, address: result.value)
//        }
//    }
//
//    func readerDidCancel(_ reader: QRCodeReaderViewController) {
//        reader.stopScanning()
//        reader.dismiss(animated: true, completion: nil)
//    }
//}
//
//extension ShopViewController: IFundsDelegate {
//    func makeDeposit() {
//        print("deposit")
//    }
//    
//    func makeWithdraw() {
//        print("withdraw")
//    }
//}
