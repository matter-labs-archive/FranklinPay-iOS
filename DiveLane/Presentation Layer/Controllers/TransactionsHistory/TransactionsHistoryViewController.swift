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

    //MARK: - Services
    let keysService: IKeysService = KeysService()
    let transactionsHistoryService = TransactionsHistoryService()
    let localDatabase = LocalDatabase()

    //MARK: - Variables
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
        guard let wallet = keysService.selectedWallet() else {
            return
        }
        guard let networkId = CurrentNetwork.currentNetwork?.chainID else {
            return
        }
        transactionsHistoryService.loadTransactions(forAddress: wallet.address, type: .custom, inNetwork: Int64(networkId)) { (result) in
            switch result {
            case .Error(let error):
                showErrorAlert(for: self, error: error, completion: {})
            case .Success(let transactions):
                self.localDatabase.saveTransactions(transactions: transactions, forWallet: wallet, completion: { (error) in
                    if let error = error {
                        showErrorAlert(for: self, error: error, completion: {})
                    } else {
                        guard let networkID = CurrentNetwork.currentNetwork?.chainID else {
                            return
                        }
                        self.prepareTransactionsForView(transactions: self.localDatabase.getAllTransactions(forWallet: wallet, andNetwork: Int64(networkID)))
                    }
                })
            }
        }
    }

    private func prepareTransactionsForView(transactions: [ETHTransactionModel]) {
        var transactions = transactions
        self.transactions.removeAll()
        //TODO: - Sort transactions by day and put them in ascending order into array
        transactions.sort { (first, second) -> Bool in
            return first.date > second.date
        }
        guard let selectedWallet = keysService.selectedWallet() else {
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
        guard let wallet = keysService.selectedWallet() else {
            return UITableViewCell()
        }
        cell.configureCell(withModel: transactions[indexPath.section][indexPath.row], andCurrentWallet: wallet)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
