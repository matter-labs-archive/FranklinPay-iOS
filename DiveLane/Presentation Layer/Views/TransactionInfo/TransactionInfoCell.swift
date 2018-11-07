//
//  TransactionInfoCell.swift
//  DiveLane
//
//  Created by Francesco on 21/10/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class TransactionInfoCell: UITableViewCell {
    static let identifier = "TransactionInfoCell"

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var detailLabel: UILabel!

    func configure(with transactionInfo: TransactionInfoController.TransactionInfo) {
        titleLabel.text = transactionInfo.infoTitle
        detailLabel.text = transactionInfo.infoValue
    }
}
