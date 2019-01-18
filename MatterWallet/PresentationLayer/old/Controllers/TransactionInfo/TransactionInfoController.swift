////
////  TransactionInfoController.swift
////  DiveLane
////
////  Created by Francesco on 05/10/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//class TransactionInfoController: UIViewController {
//    static let nibName = "TransactionInfoController"
//
//    typealias TransactionInfo = (infoTitle: String, infoValue: String)
//
//    enum Constants {
//        // MARK: Strings
//
//        static let hashTitle: String = "Hash value:"
//        static let statusTitle: String = "Status:"
//        static let directionTitle: String = "Direction:"
//        static let fromAddressTitle: String = "From:"
//        static let toAddressTitle: String = "To:"
//        static let amountTitle: String = "Amount:"
//        static let dataTitle: String = "Data:"
//        static let networkTitle: String = "Network id:"
//        static let notAvailable: String = "N/A"
//        static let directionStatusIN: String = "IN"
//        static let directionStatusOUT: String = "OUT"
//    }
//
//    enum TransictionStatus: String {
//        case isPending = "Pending..."
//        case success = "Success"
//    }
//
//    // MARK: - @IBOutlets
//
//    @IBOutlet private var tableView: UITableView!
//
//    var transactionModel: ETHTransactionModel?
//
//    private var transactionInfo = [TransactionInfo]()
//
//    private var infoValuesArray: [String] {
//        guard let transaction = transactionModel else {
//            return []
//        }
//        var infoStrings = [[String]]()
//
//        let hashString = transaction.transactionHash
//        let status: TransictionStatus = transaction.isPending ? .isPending : .success
//        let statusString = status.rawValue
//
//        let fromAddressString = transaction.from
//        let toAddressString = transaction.to
//
//        let amountString = transaction.amount
//        let networkIDString = "\(transaction.networkID)"
//
//        let directionString: String
//        let tokenAddress = transaction.token?.address
//        if  tokenAddress == transaction.from {
//            directionString = Constants.directionStatusIN
//        } else if tokenAddress == transaction.to {
//            directionString = Constants.directionStatusOUT
//        } else {
//            directionString = Constants.notAvailable
//        }
//
//        let dataString: String
//
//        if let data = transaction.data, let string = String(data: data, encoding: .utf8), !string.isEmpty {
//            dataString = string
//        } else {
//            dataString = Constants.notAvailable
//        }
//
//        infoStrings.append([
//            hashString,
//            statusString,
//            fromAddressString,
//            toAddressString,
//            amountString,
//            networkIDString,
//            directionString,
//            dataString
//            ])
//        return infoStrings.flatMap { $0 }
//    }
//
//    // MARK: - Life Cycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupTableView()
//        transactionInfo = setupTransactionDataArray(
//            infoTitles:
//            Constants.hashTitle,
//            Constants.statusTitle,
//            Constants.fromAddressTitle,
//            Constants.toAddressTitle,
//            Constants.amountTitle,
//            Constants.networkTitle,
//            Constants.directionTitle,
//            Constants.dataTitle
//        )
//    }
//
//    private func setupTableView() {
//        let nib = UINib(nibName: TransactionInfoCell.identifier, bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: TransactionInfoCell.identifier)
//        tableView.tableFooterView = UIView()
//    }
//
//    private func setupTransactionDataArray(infoTitles: String...) -> [TransactionInfo] {
//        var transactionInfoArray = [TransactionInfo]()
//        for (index, infoValue) in infoValuesArray.enumerated() {
//            let info = TransactionInfo(
//                infoTitle: infoTitles[index],
//                infoValue: infoValue
//            )
//            transactionInfoArray.append(info)
//        }
//        return transactionInfoArray
//    }
//}
//
//extension TransactionInfoController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return transactionInfo.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let reuseIdentifier = TransactionInfoCell.identifier
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TransactionInfoCell else {
//            fatalError(" we expect to use a TransactionInfoCell")
//        }
//        cell.configure(with: transactionInfo[indexPath.row])
//        return cell
//    }
//}
