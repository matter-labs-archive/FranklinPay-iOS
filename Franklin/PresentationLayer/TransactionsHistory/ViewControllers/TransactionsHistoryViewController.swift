//
//  TransactionsHistoryViewController.swift
//  DiveLane
//
//  Created by NewUser on 14/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import SideMenu

class TransactionsHistoryViewController: BasicViewController {
    
    // MARK: - Enums
    
    internal enum ScreenStatus {
        case showHistory
        case hideHistory
    }
    
    // MARK: - Outlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionsTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var marker: UIImageView!
    @IBOutlet weak var emptyTXsView: UIView!
    @IBOutlet weak var noTXsMessage: UILabel!
    @IBOutlet weak var wrongNetworkView: UIView!
    
    // MARK: - Internal lets
    
    internal let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
    
    internal let userKeys = UserDefaultKeys()
    internal var transactions = [[ETHTransaction]]()
    internal var state: TransactionsHistoryState = .all {
        didSet {
            DispatchQueue.global().async { [weak self] in
                self?.uploadTransactions()
            }
        }
    }
    
    internal var currentStatus: ScreenStatus = .showHistory {
        didSet {
            switch currentStatus {
            case .showHistory:
                wrongNetworkView.alpha = 0
                wrongNetworkView.isUserInteractionEnabled = false
            default:
                wrongNetworkView.alpha = 1
                wrongNetworkView.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Lazy vars
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = Colors.mainBlue
        
        return refreshControl
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter
    }()
    
    // MARK: - Lifesycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupNavigation()
        setupTableView()
        setupSideBar()
        additionalSetup()
        
        //txsMock()
        //CurrentWallet.currentWallet = Wallet(address: "0x832a630B949575b87C0E3C00f624f773D9B160f4", data: Data(), name: "dfad", isHD: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setScreenStatus()
        getTransactions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMarker()
    }
    
    // MARK: - Mock
    
    func txsMock() {
        transactions = [[ETHTransaction(transactionHash: "123", from: (CurrentWallet.currentWallet?.address)!, to: "Bob", amount: "123.12", date: dateFormatter.date(from: "June 10, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: false)], [ETHTransaction(transactionHash: "123", from: "Mike", to: (CurrentWallet.currentWallet?.address)!, amount: "12", date: dateFormatter.date(from: "June 09, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: false), ETHTransaction(transactionHash: "123", from: "Ann", to: (CurrentWallet.currentWallet?.address)!, amount: "12", date: dateFormatter.date(from: "June 09, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: false), ETHTransaction(transactionHash: "123", from: "Joe", to: (CurrentWallet.currentWallet?.address)!, amount: "12", date: dateFormatter.date(from: "June 09, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: false)], [ETHTransaction(transactionHash: "123", from: (CurrentWallet.currentWallet?.address)!, to: "0x0kxdmklfamdlkfm13r214dsfsd12rfsd", amount: "1", date: dateFormatter.date(from: "June 07, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: true)]]
    }
    
    // MARK: - Main setup
    
    func setScreenStatus() {
        let currentNetwork = CurrentNetwork.currentNetwork
        if currentNetwork.isRinkebi()
            || currentNetwork.isRopsten()
            || currentNetwork.isMainnet() {
            currentStatus = .showHistory
        } else {
            currentStatus = .hideHistory
        }
    }
    
    func getTransactions() {
        DispatchQueue.global().async { [unowned self] in
            self.reloadTableView()
            self.uploadTransactions()
        }
    }
    
    func additionalSetup() {
        topViewForModalAnimation.blurView()
        topViewForModalAnimation.alpha = 0
        topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        topViewForModalAnimation.isUserInteractionEnabled = false
        tabBarController?.view.addSubview(topViewForModalAnimation)
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
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

    internal func setupTableView() {
        emptyTXsView.isUserInteractionEnabled = false
        let nib = UINib(nibName: "TransactionCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransactionCell")
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        tableView.tableFooterView = footerView
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
    }

    func setupSideBar() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SettingsViewController())
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        //SideMenuManager.default.menuAddPanGestureToPresent(toView: navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: view)
        
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuWidth = 0.85 * UIScreen.main.bounds.width
        SideMenuManager.default.menuShadowOpacity = 0.5
        SideMenuManager.default.menuShadowColor = UIColor.black
        SideMenuManager.default.menuShadowRadius = 5
    }
    
    // MARK: - Updating table view
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        getTransactions()
    }
    
    internal func uploadTransactions() {
        guard let wallet = CurrentWallet.currentWallet else {
            prepareTransactionsForView(transactions: [])
            return
        }
        let net = CurrentNetwork.currentNetwork
        
        var txs = [ETHTransaction]()
        if let etherTxs = try? wallet.loadTransactions(txType: .ether, network: net) {
            txs += etherTxs
        }
        if let erc20Txs = try? wallet.loadERC20Transactions(txType: .erc20, network: net) {
            txs += erc20Txs
        }
        if let pendingTxs = try? wallet.loadPendingTransactions(network: net) {
            txs += pendingTxs
        }
        
//        guard let pendingTxs = try? wallet.loadTransactionsPool() else {
//            prepareTransactionsForView(transactions: txs)
//            return
//        }
        prepareTransactionsForView(transactions: txs)
    }
    
    internal func prepareTransactionsForView(transactions: [ETHTransaction]) {
        var txsArray = transactions
        if transactions.isEmpty {
            reloadTableView()
            return
        }
        guard let wallet = CurrentWallet.currentWallet else {return}
        // MARK: Sort transactions by day and put them in ascending order into array
        txsArray.sort { (first, second) -> Bool in
            return first.date > second.date
        }
        switch state {
        case .all:
            // TODO: - need not to be that way
            print("All right")
        case .sent:
            txsArray = txsArray.filter {
                $0.from.lowercased() == wallet.address.lowercased() && !$0.isPending
            }
        case .received:
            txsArray = txsArray.filter {
                $0.from.lowercased() != wallet.address.lowercased() && !$0.isPending
            }
        case .confirming:
            txsArray = txsArray.filter {
                $0.from.lowercased() != wallet.address.lowercased() && $0.isPending
            }
        }
        var sortedTx = [[ETHTransaction]]()
        for tx in txsArray {
            let transactionCalendarDate = calendarDate(date: tx.date)
            if sortedTx.isEmpty {
                sortedTx.append([tx])
            } else {
                guard let lastTransaction = sortedTx.last?.last else {
                    reloadTableView()
                    return
                }
                let previousTransactionCalendarDate = calendarDate(date: lastTransaction.date)
                if transactionCalendarDate.day == previousTransactionCalendarDate.day
                    && transactionCalendarDate.month == previousTransactionCalendarDate.month
                    && transactionCalendarDate.year == previousTransactionCalendarDate.year {
                    sortedTx[sortedTx.count - 1].append(tx)
                } else {
                    sortedTx.append([tx])
                }
            }
        }
        self.transactions = sortedTx
        reloadTableView()
    }
    
    internal func reloadTableView() {
        DispatchQueue.main.async { [unowned self] in
            self.emptyAttention(enabled: self.transactions.isEmpty)
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func emptyAttention(enabled: Bool) {
        DispatchQueue.main.async { [unowned self] in
            self.emptyTXsView.alpha = enabled ? 1 : 0
        }
    }
    
    // MARK: - Buttons actions

    @IBAction func changedState(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            state = .all
        case 1:
            state = .sent
        case 2:
            state = .received
        case 3:
            state = .confirming
        default:
            state = .all
        }
    }
    
    @IBAction func showMenu(_ sender: UIButton) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }

    // MARK: - Date helper

    internal func calendarDate(date: Date) -> (day: Int, month: Int, year: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return (day, month, year)
    }
}
