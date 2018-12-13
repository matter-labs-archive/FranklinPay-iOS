//
//  TransactionCell.swift
//  DiveLane
//
//  Created by NewUser on 14/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

protocol LongPressDelegate: class {
    func didLongPressCell(transaction: ETHTransactionModel?)
}

class TransactionCell: UITableViewCell {

    enum Constants {
        static let minimumPressDuration = Double(0.5)
    }

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var transactionTypeImageView: UIImageView!

    weak var longPressDelegate: LongPressDelegate?
    private var transaction: ETHTransactionModel?

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:SS"
        return dateFormatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(longPressGesture())
    }

    func configureCell(withModel model: ETHTransactionModel, andCurrentWallet currentWalet: WalletModel) {
        transaction = model
        amountLabel.text = model.amount + " " + (model.token?.symbol.uppercased() ?? "ETH")
        if model.from.lowercased() == currentWalet.address.lowercased() {
            //Sent
            transactionTypeLabel.text = "Sent"
            addressLabel.text = "To:" + model.to.hideExtraSymbolsInAddress()
            transactionTypeImageView?.image = #imageLiteral(resourceName: "sent")
        } else if model.to.lowercased() == currentWalet.address.lowercased() {
            //Received
            transactionTypeLabel.text = "Received"
            addressLabel.text = "From:" + model.from.hideExtraSymbolsInAddress()
            transactionTypeImageView.image = #imageLiteral(resourceName: "received")
        }
        timeLabel.text = dateFormatter.string(from: model.date)
    }

    func longPressGesture() -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPress.minimumPressDuration = Constants.minimumPressDuration
        return longPress
    }

    @objc func longPressAction(_ sender: UILongPressGestureRecognizer) {
        longPressDelegate?.didLongPressCell(transaction: transaction)
    }

}
