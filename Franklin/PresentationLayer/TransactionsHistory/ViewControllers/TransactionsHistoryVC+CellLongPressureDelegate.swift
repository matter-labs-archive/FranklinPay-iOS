//
//  TransactionsHistoryVC+CellLongPressureDelegate.swift
//  Franklin
//
//  Created by Anton on 21/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

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
        //        guard let topController = topViewController() else { return }
        //        topController.present(navigationController, animated: true, completion: nil)
    }
    
    internal func topViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }
}
