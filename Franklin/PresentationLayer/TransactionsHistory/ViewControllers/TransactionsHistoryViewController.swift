//
//  TransactionsHistoryViewController.swift
//  DiveLane
//
//  Created by NewUser on 14/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import SideMenu

class TransactionsHistoryViewController: BasicViewController, ModalViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionsTypeSegmentedControl: UISegmentedControl!
    
    let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)

    // MARK: - Services
//    let keysService = WalletsService()
//    let transactionsHistoryService = TransactionsHistoryService()
//    let localDatabase = TokensService()
    
    var transactions = [[ETHTransaction]]()
    var state: TransactionsHistoryState = .all {
        didSet {
            DispatchQueue.global().async { [weak self] in
                self?.uploadTransactions()
            }
        }
    }
    
    func additionalSetup() {
        self.topViewForModalAnimation.blurView()
        self.topViewForModalAnimation.alpha = 0
        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        self.topViewForModalAnimation.isUserInteractionEnabled = false
        self.tabBarController?.view.addSubview(topViewForModalAnimation)
    }

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.setupNavigation()
        self.setupTableView()
        self.setupSideBar()
        self.additionalSetup()
        
        self.txsMock()
        //CurrentWallet.currentWallet = Wallet(address: "0x832a630B949575b87C0E3C00f624f773D9B160f4", data: Data(), name: "dfad", isHD: true)
    }
    
    func txsMock() {
        self.transactions = [[ETHTransaction(transactionHash: "123", from: (CurrentWallet.currentWallet?.address)!, to: "Bob", amount: "123.12", date: dateFormatter.date(from: "June 10, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: false)], [ETHTransaction(transactionHash: "123", from: "Mike", to: (CurrentWallet.currentWallet?.address)!, amount: "12", date: dateFormatter.date(from: "June 09, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: false), ETHTransaction(transactionHash: "123", from: "Ann", to: (CurrentWallet.currentWallet?.address)!, amount: "12", date: dateFormatter.date(from: "June 09, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: false), ETHTransaction(transactionHash: "123", from: "Joe", to: (CurrentWallet.currentWallet?.address)!, amount: "12", date: dateFormatter.date(from: "June 09, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: false)], [ETHTransaction(transactionHash: "123", from: (CurrentWallet.currentWallet?.address)!, to: "0x0kxdmklfamdlkfm13r214dsfsd12rfsd", amount: "1", date: dateFormatter.date(from: "June 07, 2018")!, data: nil, token: Franklin(), networkId: 1, isPending: true)]]
    }
    
    func setupNavigation() {
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.global().async { [unowned self] in
            self.reloadTableView()
            //self.uploadTransactions()
        }
    }

    private func setupTableView() {
        let nib = UINib(nibName: "TransactionCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransactionCell")
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        tableView.tableFooterView = footerView
        tableView.delegate = self
        tableView.dataSource = self
    }

    func setupSideBar() {
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: SettingsViewController())
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        //SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.view)
        
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuWidth = 0.85 * UIScreen.main.bounds.width
        SideMenuManager.default.menuShadowOpacity = 0.5
        SideMenuManager.default.menuShadowColor = UIColor.black
        SideMenuManager.default.menuShadowRadius = 5
    }
    
    func modalViewBeenDismissed() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = 0
            })
        }
        uploadTransactions()
    }
    
    func modalViewAppeared() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
            })
        }
    }

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

    private func uploadTransactions() {
        guard let wallet = CurrentWallet.currentWallet else {
            self.prepareTransactionsForView(transactions: [])
            return
        }
        let net = CurrentNetwork.currentNetwork
        guard let txs = try? wallet.loadTransactions(txType: .custom, network: net) else {
            self.prepareTransactionsForView(transactions: [])
            return
        }
        self.prepareTransactionsForView(transactions: txs)
    }

    private func prepareTransactionsForView(transactions: [ETHTransaction]) {
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
    
    private func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func calendarDate(date: Date) -> (day: Int, month: Int, year: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return (day, month, year)
    }
    
    @IBAction func showMenu(_ sender: UIButton) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
}

extension TransactionsHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.Headers.Heights.txHistory
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions[section].count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: UIScreen.main.bounds.width,
                                        height: Constants.Headers.Heights.txHistory))
        let label = UILabel(frame: CGRect(x: 20,
                                          y: Constants.Headers.Heights.txHistory/4,
                                          width: UIScreen.main.bounds.width,
                                          height: Constants.Headers.Heights.txHistory/2))
        label.text = dateFormatter.string(from: transactions[section][0].date)
        label.font = UIFont(name: Constants.Fonts.semibold,
                            size: Constants.Headers.maximumFontSize)!
        view.backgroundColor = UIColor.white
        view.addSubview(label)
        let separator = UIView(frame: CGRect(x: 0,
                                             y: Constants.Headers.Heights.txHistory - 1,
                                             width: UIScreen.main.bounds.width,
                                             height: 1))
        separator.backgroundColor = Colors.mostLightGray
        view.addSubview(separator)
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as? TransactionCell else {
            return UITableViewCell()
        }
        guard let wallet = CurrentWallet.currentWallet else {
            return UITableViewCell()
        }
        cell.longPressDelegate = self
        cell.configureCell(with: transactions[indexPath.section][indexPath.row], wallet: wallet)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

//        let transaction = transactions[indexPath.section][indexPath.row]
//
//        let transactionInfoVC = TransactionInfoController(nibName: TransactionInfoController.nibName, bundle: nil)
//        transactionInfoVC.transactionModel = transaction
//        navigationController?.pushViewController(transactionInfoVC, animated: true)
    }

}

extension TransactionsHistoryViewController: LongPressDelegate {
    func didLongPressCell(transaction: ETHTransaction?) {
//        guard let transaction = transaction else {
//            return
//        }
//        let nibName = TransactionInfoWebController.nibName
//        let transactionInfoWebVC = TransactionInfoWebController(nibName: nibName, bundle: nil)
//        transactionInfoWebVC.transactionHash = transaction.transactionHash
//        let navigationController = UINavigationController(rootViewController: transactionInfoWebVC)
//
//        guard let topController = self.topViewController() else { return }
//        topController.present(navigationController, animated: true, completion: nil)
    }

    private func topViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
}

extension TransactionsHistoryViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        modalViewAppeared()
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        modalViewBeenDismissed()
    }
}
