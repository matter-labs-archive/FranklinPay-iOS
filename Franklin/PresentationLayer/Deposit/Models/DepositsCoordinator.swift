////
////  WalletsCoordinator.swift
////  DiveLane
////
////  Created by Anton Grigorev on 13/01/2019.
////  Copyright © 2019 Matter Inc. All rights reserved.
////
//
//import Foundation
//import BigInt
//import Web3swift
//import EthereumAddress
//
//public class DepositsCoordinator {
//    
//    func getDeposits() -> [TableDeposit] {
//        do {
//            let selectedNetwork = CurrentNetwork.currentNetwork
//            guard let currentWallet = CurrentWallet.currentWallet else {
//                return []
//            }
//            
////            let tx = try currentWallet.prepareReadContractTx(web3instance: nil, contractABI: CreditAbi, contractAddress: CreditAddress, contractMethod: "getDeposits", gasLimit: .automatic, gasPrice: .automatic, parameters: [EthereumAddress(currentWallet.address)!], extraData: Data())
////            let result = try currentWallet.callTx(transaction: tx)
//            
//            let allDeposits: [[String: String]] = [["date": "15.12.2019",
//                                                    "amount": "100.12"],
//                                                   ["date": "12.12.2020",
//                                                    "amount": "10.0"]]
//            var depositsArray = [TableDeposit]()
//            for deposit in allDeposits {
//                let tableDeposit = TableDeposit(date: deposit["date"] ?? "0.0.0",
//                                                amount: deposit["amount"] ?? "0.0")
//                depositsArray.append(tableDeposit)
//            }
//            return depositsArray
//        } catch {
//            return []
//        }
//    }
//}
