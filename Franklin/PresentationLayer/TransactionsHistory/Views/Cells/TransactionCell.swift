//
//  TransactionCell.swift
//  DiveLane
//
//  Created by NewUser on 14/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import BigInt

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
        
//        let amount: String
//        let address: String
//        
//        if let hex = model.data?.toHexString() {
//            let count = hex.count
//            if count == 136 {
//                let id: String = "a9059cbb"
//                let methodID = hex.contains(id)
//                if methodID {
//                    //getting value
//                    var valueHex = hex
//                    valueHex.removeFirst(74)
//                    let trimmedValueHex = valueHex.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
//                    if let value = UInt64(trimmedValueHex, radix: 16) {
//                        let bn = BigUInt(value)
//                        amount = bn.getConvinientRepresentationBalance
//                    }
//                    //getting address
//                    var addressHex = hex
//                    addressHex.removeLast(64)
//                    addressHex.removeFirst(8)
//                    let trimmedAddressHex = addressHex.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
//                    address = trimmedAddressHex
//                }
//            }
//        } else {
//            amount = model.amount
//            
//        }
        let token = model.token ?? Ether()
        let symbol = token.symbol
        
        amountLabel.text = "\(model.amount) \(symbol)"
        if model.from.lowercased() == wallet.address.lowercased() {
            //Sent
            if model.isPending {
                transactionTypeImageView?.image = UIImage(named: "pending")
                timeLabel.text = "Tap to view or cancel"
            } else {
                transactionTypeImageView?.image = UIImage(named: "to")
                timeLabel.text = dateFormatter.string(from: model.date)
            }
            addressLabel.text = "To " + model.to.hideExtraSymbolsInAddress()
            
        } else if model.to.lowercased() == wallet.address.lowercased() {
            //Received
            if model.isPending {
                transactionTypeImageView?.image = UIImage(named: "pending")
                timeLabel.text = "Tap to view or cancel"
            } else {
                transactionTypeImageView?.image = UIImage(named: "from")
                timeLabel.text = dateFormatter.string(from: model.date)
            }
            addressLabel.text = "From " + model.from.hideExtraSymbolsInAddress()
        }
        
//        if let hex = model.data?.toHexString() {
//            let count = hex.count
//            if count == 136 {
//                let id: String = "a9059cbb"
//                let methodID = hex.contains(id)
//                if methodID {
//                    //getting value
//                    var valueHex = hex
//                    valueHex.removeFirst(74)
//                    let trimmedValueHex = valueHex.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
//                    if let value = UInt64(trimmedValueHex, radix: 16) {
//                        let bn = BigUInt(value)
//                        let val = bn.getConvinientRepresentationBalance
//                        amountLabel.text = "\(val)"
//                    }
//                    //getting address
//                    var addressHex = hex
//                    addressHex.removeLast(64)
//                    addressHex.removeFirst(8)
//                    let trimmedAddressHex = addressHex.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
//                    addressLabel.text
//                }
//            }
//        }
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
