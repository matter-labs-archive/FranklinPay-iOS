//
//  TransactionsHistoryViewController.swift
//  DiveLane
//
//  Created by NewUser on 14/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class TransactionsHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transactionsTypeSegmentedControl: UISegmentedControl!

    let animationController = AnimationController()

    // MARK: - Services
    let keysService = WalletsService()
    let transactionsHistoryService = TransactionsHistoryService()
    let localDatabase = TokensStorage()

    // MARK: - Variables
    var transactions = [[ETHTransactionModel]]()
    var state: TransactionsHistoryState = .all {
        didSet {
            uploadTransactions()
        }
    }

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        uploadTransactions()
        self.navigationItem.setRightBarButton(settingsWalletBarItem(), animated: false)
    }
    
    private func settingsWalletBarItem() -> UIBarButtonItem {
        let addButton = UIBarButtonItem(image: UIImage(named: "settings_blue"),
                                        style: .plain,
                                        target: self,
                                        action: #selector(settingsWallet))
        return addButton
    }
    
    @objc func settingsWallet() {
        //let walletsViewController = WalletsViewController()
        let settingsViewController = SettingsViewController()
        self.navigationController?.pushViewController(settingsViewController, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uploadTransactions()
    }

    private func setupTableView() {
        let nib = UINib(nibName: "TransactionCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransactionCell")
        tableView.delegate = self
        tableView.dataSource = self
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
        animationController.waitAnimation(isEnabled: true,
                                notificationText: "Downloading transactions",
                                on: self.view)
        do {
            let wallet = try keysService.getSelectedWallet()
            guard let networkId = CurrentNetwork.currentNetwork?.chainID else {
                return
            }
            let result = try transactionsHistoryService.loadTransactions(for: wallet.address, txType: .custom, networkId: Int64(networkId))
            DispatchQueue.main.async { [weak self] in
                self?.animationController.waitAnimation(isEnabled: false,
                                                        on: (self?.view)!)
            }
            try TransactionsStorage().saveTransactions(transactions: result, for: wallet)
            guard let networkID = CurrentNetwork.currentNetwork?.chainID else {
                return
            }
            let txs = try TransactionsStorage().getAllTransactions(for: wallet, networkId: Int64(networkID))
            self.prepareTransactionsForView(transactions: txs)
        } catch let error {
            Alerts().showErrorAlert(for: self, error: error, completion: {})
        }
    }

    private func prepareTransactionsForView(transactions: [ETHTransactionModel]) {
        var transactions = transactions
        self.transactions.removeAll()
        // MARK: Sort transactions by day and put them in ascending order into array
        transactions.sort { (first, second) -> Bool in
            return first.date > second.date
        }
        guard let selectedWallet = try? keysService.getSelectedWallet() else {
            return
        }
        switch state {
        case .all:
            print("All right")
        case .sent:
            transactions = transactions.filter {
                $0.from.lowercased() == selectedWallet.address.lowercased() && !$0.isPending
            }
        case .received:
            transactions = transactions.filter {
                $0.from.lowercased() != selectedWallet.address.lowercased() && !$0.isPending
            }
        case .confirming:
            transactions = transactions.filter {
                $0.isPending
            }
        }
        for transaction in transactions {
            let transactionCalendarDate = calendarDate(date: transaction.date)
            if self.transactions.isEmpty {
                self.transactions.append([transaction])
            } else {
                guard let lastTransaction = self.transactions.last?.last else {
                    return
                }
                let previousTransactionCalendarDate = calendarDate(date: lastTransaction.date)
                if transactionCalendarDate.day == previousTransactionCalendarDate.day
                           && transactionCalendarDate.month == previousTransactionCalendarDate.month
                           && transactionCalendarDate.year == previousTransactionCalendarDate.year {
                    self.transactions[self.transactions.count - 1].append(transaction)
                } else {
                    self.transactions.append([transaction])
                }
            }
        }
        tableView.reloadData()
    }

    private func calendarDate(date: Date) -> (day: Int, month: Int, year: Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return (day, month, year)
    }
}

extension TransactionsHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactions.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions[section].count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 46))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 22))
        label.text = dateFormatter.string(from: transactions[section][0].date)
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        view.backgroundColor = UIColor.white
        view.addSubview(label)
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as? TransactionCell else {
            return UITableViewCell()
        }
        guard let wallet = try? keysService.getSelectedWallet() else {
            return UITableViewCell()
        }
        cell.longPressDelegate = self
        cell.configureCell(withModel: transactions[indexPath.section][indexPath.row], andCurrentWallet: wallet)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let transaction = transactions[indexPath.section][indexPath.row]

        let transactionInfoVC = TransactionInfoController(nibName: TransactionInfoController.nibName, bundle: nil)
        transactionInfoVC.transactionModel = transaction
        navigationController?.pushViewController(transactionInfoVC, animated: true)
    }

}

extension TransactionsHistoryViewController: LongPressDelegate {
    func didLongPressCell(transaction: ETHTransactionModel?) {
        guard let transaction = transaction else {
            return
        }
        let nibName = TransactionInfoWebController.nibName
        let transactionInfoWebVC = TransactionInfoWebController(nibName: nibName, bundle: nil)
        transactionInfoWebVC.transactionHash = transaction.transactionHash
        let navigationController = UINavigationController(rootViewController: transactionInfoWebVC)

        guard let topController = self.topViewController() else { return }
        topController.present(navigationController, animated: true, completion: nil)
    }

    private func topViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
}
