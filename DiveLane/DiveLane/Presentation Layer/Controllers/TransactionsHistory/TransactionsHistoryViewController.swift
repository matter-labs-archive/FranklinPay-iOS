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
    let transactionsService = TransactionsService()
    
    //MARK: - Variables
    var transactions = [[ETHTransactionModel]]()
    var state: TransactionsHistoryState = .all
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TransactionCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TransactionCell")
        tableView.delegate = self
        tableView.dataSource = self
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell") as? TransactionCell else { return UITableViewCell() }
        guard let wallet = keysService.selectedWallet() else { return UITableViewCell() }
        cell.configureCell(withModel: transactions[indexPath.section][indexPath.row], andCurrentWallet: wallet)
        return cell
    }
    
}
