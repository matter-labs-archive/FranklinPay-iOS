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
//
//public class CreditsCoordinator {
//    
//    func getCredits() -> [TableCredit] {
//        do {
//            let selectedNetwork = CurrentNetwork.currentNetwork
//            guard let currentWallet = CurrentWallet.currentWallet else {
//                return []
//            }
//            
//            //            let tx = try currentWallet.prepareReadContractTx(web3instance: nil, contractABI: CreditAbi, contractAddress: CreditAddress, contractMethod: "getCredits", gasLimit: .automatic, gasPrice: .automatic, parameters: [EthereumAddress(currentWallet.address)!], extraData: Data())
//            //            let result = try currentWallet.callTx(transaction: tx)
//            
//            let allCredits: [[String: String]] = [["date": "10.05.2019",
//                                                    "amount": "10.01"],
//                                                   ["date": "12.10.2020",
//                                                    "amount": "109.0"]]
//            var creditsArray = [TableCredit]()
//            for credit in allCredits {
//                let tableCredit = TableCredit(date: credit["date"] ?? "0.0.0",
//                                                amount: credit["amount"] ?? "0.0")
//                creditsArray.append(tableCredit)
//            }
//            return creditsArray
//        } catch {
//            return []
//        }
//    }
//}
