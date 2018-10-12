//
//  TransactionInfoController.swift
//  DiveLane
//
//  Created by Francesco on 05/10/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class TransactionInfoController: UIViewController {

    // MARK: - Views

    private var transactionInfoView: TransactionInfoView? = {
        let view: TransactionInfoView? = TransactionInfoView.loadFromNib()
        return view
    }()

    // MARK: - Init

    init(transaction: ETHTransactionModel) {
        super.init(nibName: nil, bundle: nil)
        setupView(with: transaction)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(with transaction: ETHTransactionModel) {

        guard let transactionInfoView = transactionInfoView else { return }

        view.addSubview(transactionInfoView)
        transactionInfoView.anchorToSuperview()
        transactionInfoView.configure(with: transaction)
    }
}
