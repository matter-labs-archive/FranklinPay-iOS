//
//  TransactionCell.swift
//  DiveLane
//
//  Created by NewUser on 14/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

protocol LongPressDelegate: class {
    func didLongPressCell(transaction: ETHTransaction?)
}

class TransactionCell: UITableViewCell {

    enum Constants {
        static let minimumPressDuration = Double(0.5)
    }

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var transactionTypeImageView: UIImageView!

    weak var longPressDelegate: LongPressDelegate?
    private var transaction: ETHTransaction?

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:SS"
        return dateFormatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(longPressGesture())
    }

    func configureCell(with model: ETHTransaction, wallet: Wallet) {
        transaction = model
        amountLabel.text = "$ \(model.amount)"
        if model.from.lowercased() == wallet.address.lowercased() {
            //Sent
            if model.isPending {
                transactionTypeImageView?.image = UIImage(named: "pending")
            } else {
                transactionTypeImageView?.image = UIImage(named: "to")
            }
            addressLabel.text = "To " + model.to.hideExtraSymbolsInAddress()
            timeLabel.text = dateFormatter.string(from: model.date)
        } else if model.to.lowercased() == wallet.address.lowercased() {
            //Received
            if model.isPending {
                transactionTypeImageView?.image = UIImage(named: "pending")
            } else {
                transactionTypeImageView?.image = UIImage(named: "from")
            }
            addressLabel.text = "From " + model.from.hideExtraSymbolsInAddress()
            timeLabel.text = "Tap to view or cancel"
        }
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
