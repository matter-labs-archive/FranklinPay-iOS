//
//  TransactionInfoView.swift
//  DiveLane
//
//  Created by Francesco on 12/10/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class TransactionInfoView: UIView {

    enum Constants {
        // MARK: Strings

        static let hashTitle: String = "Hash value: "
        static let statusTitle: String = "Status: "
        static let directionTitle: String = "Direction: "
        static let fromAddressTitle: String = "From: "
        static let toAddressTitle: String = "To: "
        static let amountTitle: String = "Amount: "
        static let dataTitle: String = "Data: "
        static let networkTitle: String = "Network id: "
        static let notAvailable: String = "N/A"
        static let directionStatusIN: String = "IN"
        static let directionStatusOUT: String = "OUT"
    }

    enum TransictionStatus: String {
        case isPending = "Pending..."
        case success = "Success"
    }

    // MARK: @IBOutlets

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var infoStackView: UIStackView!
    @IBOutlet private var hashLabel: MaterialLabel!
    @IBOutlet private var statusLabel: MaterialLabel!
    @IBOutlet private var directionLabel: MaterialLabel!
    @IBOutlet private var fromAddressLabel: MaterialLabel!
    @IBOutlet private var toAddressLabel: MaterialLabel!
    @IBOutlet private var amountLabel: MaterialLabel!
    @IBOutlet private var dataLabel: MaterialLabel!
    @IBOutlet private var networkLabel: MaterialLabel!

    func configure(with transaction: ETHTransactionModel) {
        setupStrings(
            infoStringsArray(for: transaction),
            for: hashLabel,
            statusLabel,
            fromAddressLabel,
            toAddressLabel,
            amountLabel,
            networkLabel,
            directionLabel,
            dataLabel
        )
    }

    func infoStringsArray(for transaction: ETHTransactionModel) -> [String] {
        var infoStrings = [[String]]()

        let hashString = Constants.hashTitle + transaction.transactionHash
        let status: TransictionStatus = transaction.isPending ? .isPending : .success
        let statusString = Constants.statusTitle + status.rawValue

        let fromAddressString = Constants.fromAddressTitle + transaction.from
        let toAddressString = Constants.toAddressTitle + transaction.to

        let amountString = Constants.amountTitle + transaction.amount
        let networkIDString = Constants.networkTitle + "\(transaction.networkID)"

        var directionString: String = Constants.directionTitle
        let tokenAddress = transaction.token?.address
        if  tokenAddress == transaction.from {
            directionString.append(Constants.directionStatusIN)
        } else if tokenAddress == transaction.to {
            directionString.append(Constants.directionStatusOUT)
        } else {
            directionString.append(Constants.notAvailable)
        }

        var dataString = Constants.dataTitle

        if let data = transaction.data, let string = String(data: data, encoding: .utf8), !string.isEmpty {
            dataString.append(string)
        } else {
            dataString.append(Constants.notAvailable)
        }

        infoStrings.append([
            hashString,
            statusString,
            fromAddressString,
            toAddressString,
            amountString,
            networkIDString,
            directionString,
            dataString
        ])
        return infoStrings.flatMap { $0 }
    }

    func setupStrings(_ strings: [String], for labels: UILabel...) {
        zip(labels, strings).forEach { label, string in
            label.text = string
        }
    }

}
