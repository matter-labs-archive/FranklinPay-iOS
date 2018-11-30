//
//  AppControllerRouter.swift
//  DiveLane
//
//  Created by NewUser on 27/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import BigInt

class EIP681Router {
//    let transactionsService = Web3Service()
//    let etherscanService = ContractsService()
//    let model = EIP681Model()
//    public func sendCustomTransaction(parsed: Web3.EIP681Code, usingWindow window: UIWindow) {
//        switch parsed.functionName {
//        case "transfer":
//            sendERC20TokenTransaction(parsed: parsed, usingWindow: window)
//        default:
//            sendArbitraryTransactionToContract(parsed: parsed, usingWindow: window)
//        }
//    }
//    public func sendETHTransaction(parsed: Web3.EIP681Code, usingWindow window: UIWindow) {
//        let targetAddress = model.getParsedAddress(targetAddress: parsed.targetAddress)
//        let controller = SendSettingsViewController(tokenAddress: "",
//                                                    amount: parsed.amount ?? 0,
//                                                    destinationAddress: targetAddress.address,
//                                                    isFromDeepLink: true)
//        self.showController(controller, window: window)
//    }
//    public func sendERC20TokenTransaction(parsed: Web3.EIP681Code, usingWindow window: UIWindow) {
//        let tokenAddress = parsed.function?.inputs[0].name
//        guard let amount = parsed.function?.inputs[1].name else { return }
//        let targetAddress = model.getParsedAddress(targetAddress: parsed.targetAddress)
//        let controller = SendSettingsViewController(tokenAddress: tokenAddress,
//                                                    amount: BigUInt(amount)!,
//                                                    destinationAddress: targetAddress.address,
//                                                    isFromDeepLink: true)
//        showController(controller, window: window)
//    }
//    public func sendArbitraryTransactionToContract(parsed: Web3.EIP681Code, usingWindow window: UIWindow) {
//        model.changeCurrentNetowrk(chainId: parsed.chainID)
//        let web3 = web3swift.web3(provider: InfuraProvider(CurrentNetwork.currentNetwork ?? Networks.Mainnet)!)
//        CurrentWeb.currentWeb = web3
//        //Preparing the options
//        var options: Web3Options = Web3Options.defaultOptions()
//        options.gasLimit = parsed.gasLimit
//        options.gasPrice = parsed.gasPrice
//        options.value = parsed.amount
//        let contractAddress = model.getParsedAddress(targetAddress: parsed.targetAddress)
//        guard let methodName = parsed.functionName else { return }
//        guard let params = parsed.function?.inputs.map({ return Parameter(type: $0.type.abiRepresentation,
//                                                                          value: $0.name) }) else {
//                                                                            return
//        }
//        let data = parsed.parameters.map {
//            return $0.value
//        }
//        findABI(contractAddress: contractAddress,
//                params: params,
//                data: data,
//                methodName: methodName,
//                options: options,
//                usingWindow: window)
//    }
//    public func findABI(contractAddress: EthereumAddress, params: [Parameter], data: [AnyObject],
//                        methodName: String, options: Web3Options, usingWindow window: UIWindow) {
//        etherscanService.getAbi(forContractAddress: contractAddress.address) { (result) in
//            switch result {
//            case .Success(let abi):
//                self.showArbitratySendingScreen(data: data, params: params,
//                                                contractAddress: contractAddress,
//                                                contractAbi: abi, methodName: methodName,
//                                                options: options, usingWindow: window)
//            case .Error:
//                //If there is no ABI posted on etherscan.
//                let contractAbi = self.model.getContractABI(contractAddress: contractAddress)
//                self.showArbitratySendingScreen(data: data, params: params,
//                                                contractAddress: contractAddress, contractAbi: contractAbi,
//                                                methodName: methodName, options: options, usingWindow: window)
//            }
//        }
//    }
//    public func showArbitratySendingScreen(data: [AnyObject],
//                                           params: [Parameter],
//                                           contractAddress: EthereumAddress,
//                                           contractAbi: String,
//                                           methodName: String,
//                                           options: Web3Options,
//                                           usingWindow window: UIWindow) {
//        self.transactionsService
//            .prepareTransactionToContract(
//                data: data,
//                contractAbi: contractAbi,
//                contractAddress: contractAddress.address,
//                method: methodName,
//                predefinedOptions: options) { (result) in
//                    switch result {
//                    case .Error(let error):
//                        let controller = AppController().goToApp()
//                        self.showController(controller,
//                                            window: window)
//                        showErrorAlert(for: controller,
//                                       error: error,
//                                       completion: nil)
//                    case .Success(let intermediate):
//                        let controller = SendArbitraryTransactionViewController(
//                            params: params,
//                            transactionInfo:
//                            TransactionInfo(
//                                contractAddress: contractAddress.address,
//                                transactionIntermediate:
//                                intermediate,
//                                methodName: methodName)
//                        )
//                        self.showController(controller,
//                                            window: window)
//                    }
//        }
//    }
//    private func showController(_ controller: UIViewController, window: UIWindow) {
//        window.rootViewController = controller
//        window.makeKeyAndVisible()
//    }
}
