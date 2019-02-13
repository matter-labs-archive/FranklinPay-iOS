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
import SideMenu
import QRCodeReader

enum WalletSections: Int {
    case franklin = 0
    case tokens = 1
}

class WalletViewController: BasicViewController, ModalViewDelegate {

    @IBOutlet weak var walletTableView: BasicTableView!
    @IBOutlet weak var sendMoneyButton: BasicBlueButton!
    @IBOutlet weak var scanQrButton: ScanButton!
    @IBOutlet weak var marker: UIImageView!
    
    private let userKeys = UserDefaultKeys()
    private var tokensService = TokensService()
    private var walletsService = WalletsService()
    private var tokensArray: [TableToken] = []
    
    private let walletSections: [WalletSections] = [.franklin, .tokens]

    private let alerts = Alerts()
    private let etherCoordinator = EtherCoordinator()
    
    let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
        #selector(self.handleRefresh(_:)),
                for: UIControl.Event.valueChanged)
        //refreshControl.alpha = 0
        refreshControl.tintColor = Colors.mainBlue

        return refreshControl
    }()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }

        return QRCodeReaderViewController(builder: builder)
    }()
    
    @IBAction func qrScanTapped(_ sender: Any) {
        readerVC.delegate = self

        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
        }
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.parent?.view.backgroundColor = .white
        self.view.alpha = 0
        self.view.backgroundColor = Colors.background
        self.tabBarController?.tabBar.selectedItem?.title = nil
        self.setupNavigation()
        self.setupTableView()
        self.additionalSetup()
        self.setupSideBar()
        self.additionalSetup()
    }
    
    func setupMarker() {
        self.marker.isUserInteractionEnabled = false
        guard let wallet = CurrentWallet.currentWallet else {
            return
        }
        if userKeys.isBackupReady(for: wallet) {
            self.marker.alpha = 0
        } else {
            self.marker.alpha = 1
        }
    }
    
    func additionalSetup() {
        self.sendMoneyButton.setTitle("Send money", for: .normal)
        self.topViewForModalAnimation.blurView()
        self.topViewForModalAnimation.alpha = 0
        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        self.topViewForModalAnimation.isUserInteractionEnabled = false
        self.tabBarController?.view.addSubview(topViewForModalAnimation)
    }
    
    func setupSideBar() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SettingsViewController())
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        
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
        self.walletTableView.delegate = self
        self.walletTableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        self.walletTableView.tableFooterView = footerView
        self.walletTableView.addSubview(self.refreshControl)
        self.walletTableView.register(nibToken, forCellReuseIdentifier: "TokenCell")
        self.walletTableView.register(nibCard, forCellReuseIdentifier: "CardCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupMarker()
        self.appearAnimation()
        self.setTokensList()
        
//        print(CurrentWallet.currentWallet?.address)
//        print(try? walletsService.getSelectedWallet().address)
//        guard let wallets = try? walletsService.getAllWallets() else {return}
//        for w in wallets {
//            print(w.address)
//        }
    }
    
    func appearAnimation() {
        UIView.animate(withDuration: Constants.ModalView.animationDuration) { [unowned self] in
            self.view.alpha = 1
        }
    }

    func setupNavigation() {
        self.navigationController?.navigationBar.isHidden = true
    }

    func clearData() {
        tokensArray.removeAll()
    }
    
    func setTokensList() {
        self.clearData()
        DispatchQueue.global().async { [unowned self] in
            let tokens = self.etherCoordinator.getTokens()
            self.tokensArray = tokens
            self.reloadDataInTable(completion: { [unowned self] in
                self.updateTokensBalances { [unowned self] in
                    self.reloadDataInTable { [unowned self] in
                        self.saveTokensBalances()
                        // TODO: - need to update rates?
                    }
                }
            })
        }
    }
    
    @IBAction func showMenu(_ sender: Any) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.updateTokensBalances { [unowned self] in
            self.reloadDataInTable { [unowned self] in
                self.saveTokensBalances()
                self.refreshControl.endRefreshing()
            }
        }
    }

    func reloadDataInTable(completion: @escaping () -> Void) {
        DispatchQueue.main.async { [unowned self] in
            self.walletTableView.reloadData()
            completion()
        }
    }

    func updateTokenRow(rowIndexPath: IndexPath) {
        DispatchQueue.main.async { [unowned self] in
            self.walletTableView.reloadRows(at: [rowIndexPath], with: .none)
        }
    }

    func updateTokensBalances(completion: @escaping () -> Void) {
        DispatchQueue.global().async { [unowned self] in
            var index = 0
            for tabToken in self.tokensArray {
                var currentTableToken = tabToken
                let currentToken = tabToken.token
                let currentWallet = tabToken.inWallet
                let balance: String = self.etherCoordinator.getBalance(for: currentToken, wallet: currentWallet)
                currentToken.balance = balance
                currentTableToken.token = currentToken
                self.tokensArray[index] = currentTableToken
                index += 1
            }
            completion()
        }
    }
    
    func saveTokensBalances() {
        for tabToken in tokensArray {
            let currentToken = tabToken.token
            let currentWallet = tabToken.inWallet
            let currentNetwork = CurrentNetwork.currentNetwork
            if let balance = currentToken.balance {
                try? currentToken.saveBalance(in: currentWallet, network: currentNetwork, balance: balance)
            }
        }
    }
    
//        guard !self.ratesUpdating else {return}
//        self.ratesUpdating = true
//        guard !self.twoDimensionalTokensArray.isEmpty else {return}
//        var indexPath = IndexPath(row: 0, section: 0)
//        for wallet in self.twoDimensionalTokensArray {
//            for token in wallet.tokens {
//                var currentTableToken = token
//                let currentToken = token.token
//                let currentWallet = token.inWallet
//                let balance = self.etherCoordinator.getBalance(for: currentToken, wallet: currentWallet)
//                currentToken.balance = balance
//                let balanceInDollars = self.etherCoordinator.getBalanceInDollars(for: token.token, withBalance: balance)
//                currentToken.usdBalance = balanceInDollars
//                currentTableToken.token = currentToken
//                self.twoDimensionalTokensArray[indexPath.section].tokens[indexPath.row] = currentTableToken
////                    let ip = indexPath
////                    self.updateTokenRow(rowIndexPath: ip)
//                try? token.inWallet.setBalance(token: currentToken, network: CurrentNetwork.currentNetwork, balance: balance)
//                try? token.inWallet.setUsdBalance(token: currentToken, network: CurrentNetwork.currentNetwork, usdBalance: balanceInDollars)
//                indexPath.row += 1
//            }
//            indexPath.section += 1
//            indexPath.row = 0
//        }
//        self.ratesUpdating = false
//        completion()
//    }

    func deleteToken(in indexPath: IndexPath) {
        let token = self.tokensArray[indexPath.row].token
        let wallet = self.tokensArray[indexPath.row].inWallet
        let network = CurrentNetwork.currentNetwork
        let isEtherToken = token == Ether()
        let isFranklin = token == Franklin()
        if isEtherToken {return}
        if isFranklin {return}
        do {
            try wallet.delete(token: token, network: network)
            CurrentToken.currentToken = Franklin()
            self.setTokensList()
        } catch let error {
            self.alerts.showErrorAlert(for: self, error: error, completion: nil)
        }
    }

//    func didPressAdd(sender: UIButton) {
//        guard let wallet = CurrentWallet.currentWallet else {
//            self.alerts.showErrorAlert(for: self, error: "Can't select wallet", completion: nil)
//            return
//        }
//        let searchTokenController = SearchTokenViewController(for: wallet)
//        self.navigationController?.pushViewController(searchTokenController, animated: true)
//    }
    
    func modalViewBeenDismissed() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = 0
            })
        }
    }
    
    func modalViewAppeared() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
            })
        }
    }
    
    @IBAction func writeCheque(_ sender: UIButton) {
        self.modalViewAppeared()
        let token = tokensArray[0].token
        let sendMoneyVC = SendMoneyController(token: token)
        sendMoneyVC.delegate = self
        sendMoneyVC.modalPresentationStyle = .overCurrentContext
        sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
        self.tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
    }
    
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource, TableHeaderDelegate {
    
    func didPressAdd(sender: UIButton) {
        self.modalViewAppeared()
        guard let wallet = CurrentWallet.currentWallet else {return}
        let sendMoneyVC = SearchTokenViewController(for: wallet)
        sendMoneyVC.delegate = self
        sendMoneyVC.modalPresentationStyle = .overCurrentContext
        sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
        self.tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let wallet = CurrentWallet.currentWallet else {return nil}
        let background: TableHeader = TableHeader(for: wallet)
        background.delegate = self
        return background
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case WalletSections.franklin.rawValue:
            return 0
        case WalletSections.tokens.rawValue:
            return Constants.Headers.Heights.tokens
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case WalletSections.franklin.rawValue:
            return UIScreen.main.bounds.height * Constants.CardCell.heightCoef
        case WalletSections.tokens.rawValue:
            return UIScreen.main.bounds.height * Constants.TokenCell.heightCoef
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return walletSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case WalletSections.franklin.rawValue:
            return 1
        case WalletSections.tokens.rawValue:
            return tokensArray.count - 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tokensArray.isEmpty {return UITableViewCell()}
        let franklin = tokensArray[0]
        var tokens = tokensArray
        tokens.removeFirst()
        switch indexPath.section {
        case WalletSections.franklin.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell",
                                                           for: indexPath) as? CardCell else {
                                                            return UITableViewCell()
            }
            let tableToken = franklin
            cell.configure(token: tableToken)
            cell.delegate = self
            return cell
        case WalletSections.tokens.rawValue:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokenCell",
                                                           for: indexPath) as? TokenCell else {
                                                            return UITableViewCell()
            }
            let tableToken = tokens[indexPath.row]
            cell.configure(token: tableToken)
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
            return
        }
        let cell = indexPath.section == WalletSections.franklin.rawValue ?
            tableView.cellForRow(at: indexPathForSelectedRow) as? CardCell :
            tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell
        guard let selectedCell = cell else {
            return
        }
        guard let indexPathTapped = self.walletTableView.indexPath(for: selectedCell) else {
            return
        }
        let tableToken = indexPath.section == WalletSections.franklin.rawValue ?
            self.tokensArray[0] :
            self.tokensArray[indexPathTapped.row+1]
        self.modalViewAppeared()
        let sendMoneyVC = SendMoneyController(token: tableToken.token)
        sendMoneyVC.delegate = self
        sendMoneyVC.modalPresentationStyle = .overCurrentContext
        sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
        self.tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteToken(in: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let indexPathForSelectedRow = tableView.indexPathForSelectedRow else {
            return false
        }
        if indexPath.section == WalletSections.franklin.rawValue {
            return false
        }
        let cell = tableView.cellForRow(at: indexPathForSelectedRow) as? TokenCell
        guard let selectedCell = cell else {
            return false
        }
        guard let indexPathTapped = self.walletTableView.indexPath(for: selectedCell) else {
            return false
        }
        let token = self.tokensArray[indexPathTapped.row].token
        if token.isEther() || token.isDai() {
            return false
        }
        return true
    }
}

extension WalletViewController: CardCellDelegate {
    func cardInfoTapped(_ sender: CardCell) {
        guard let indexPathTapped = self.walletTableView.indexPath(for: sender) else {
            return
        }
        let wallet = self.tokensArray[indexPathTapped.row].inWallet
        self.modalViewAppeared()
        let publicKeyController = PublicKeyViewController(for: wallet)
        publicKeyController.delegate = self
        publicKeyController.modalPresentationStyle = .overCurrentContext
        publicKeyController.view.layer.speed = Constants.ModalView.animationSpeed
        self.tabBarController?.present(publicKeyController, animated: true, completion: nil)
    }
}

extension WalletViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        modalViewAppeared()
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        modalViewBeenDismissed()
    }
}

extension WalletViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        reader.dismiss(animated: true) { [unowned self] in
            self.modalViewAppeared()
            let token = self.tokensArray[0].token
            let sendMoneyVC = SendMoneyController(token: token, address: result.value)
            sendMoneyVC.delegate = self
            sendMoneyVC.modalPresentationStyle = .overCurrentContext
            sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
            self.tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
        }
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
}
