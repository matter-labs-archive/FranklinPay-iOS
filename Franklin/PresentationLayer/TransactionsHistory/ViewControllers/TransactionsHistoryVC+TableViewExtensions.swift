//
//  TransactionsHistoryVC+TableViewExtensions.swift
//  Franklin
//
//  Created by Anton on 21/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

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
        label.font = UIFont(name: Constants.Fonts.regular,
                            size: Constants.Headers.leftItemTransactionsFontSize)!
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
