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
import EthereumAddress

class EIP681Router {
    let etherscanService = ContractsService()
    let model = EIP681Model()
    public func sendCustomTransaction(parsed: Web3.EIP681Code, usingWindow window: UIWindow) {
        switch parsed.functionName {
        case "transfer":
            sendERC20TokenTransaction(parsed: parsed, usingWindow: window)
        default:
            sendArbitraryTransactionToContract(parsed: parsed, usingWindow: window)
        }
    }
    public func sendETHTransaction(parsed: Web3.EIP681Code, usingWindow window: UIWindow) {
        let targetAddress = model.getParsedAddress(targetAddress: parsed.targetAddress)
        //TODO
//        let controller = SendSettingsViewController(tokenAddress: "",
//                                                    amount: parsed.amount ?? 0,
//                                                    destinationAddress: targetAddress.address,
//                                                    isFromDeepLink: true)
//        self.showController(controller, window: window)
    }
    public func sendERC20TokenTransaction(parsed: Web3.EIP681Code, usingWindow window: UIWindow) {
        let tokenAddress = parsed.function?.inputs[0].name
        guard let amount = parsed.function?.inputs[1].name else { return }
        let targetAddress = model.getParsedAddress(targetAddress: parsed.targetAddress)
        //TODO
//        let controller = SendSettingsViewController(tokenAddress: tokenAddress,
//                                                    amount: BigUInt(amount)!,
//                                                    destinationAddress: targetAddress.address,
//                                                    isFromDeepLink: true)
//        showController(controller, window: window)
    }
    public func sendArbitraryTransactionToContract(parsed: Web3.EIP681Code, usingWindow window: UIWindow) {
        model.changeCurrentNetowrk(chainId: parsed.chainID)
        //Preparing the options
        var options: TransactionOptions = TransactionOptions.defaultOptions
        if let gl = parsed.gasLimit {
            options.gasLimit = .manual(gl)
        } else {
            options.gasLimit = .automatic
        }
        if let gp = parsed.gasPrice {
            options.gasPrice = .manual(gp)
        } else {
            options.gasPrice = .automatic
        }
        options.value = parsed.amount
        let contractAddress = model.getParsedAddress(targetAddress: parsed.targetAddress)
        guard let methodName = parsed.functionName else { return }
        guard let params = parsed.function?.inputs.map({ return Parameter(type: $0.type.abiRepresentation,
                                                                          value: $0.name) }) else {
                                                                            return
        }
        let data = parsed.parameters.map {
            return $0.value
        }
        findABI(contractAddress: contractAddress,
                params: params,
                data: data,
                methodName: methodName,
                options: options,
                usingWindow: window)
    }
    public func findABI(contractAddress: EthereumAddress, params: [Parameter], data: [AnyObject],
                        methodName: String, options: TransactionOptions, usingWindow window: UIWindow) {
        if let abi = try? etherscanService.getAbi(for: contractAddress.address) {
            self.showArbitratySendingScreen(data: data,
                                            params: params,
                                            contractAddress: contractAddress,
                                            contractAbi: abi,
                                            methodName: methodName,
                                            options: options,
                                            usingWindow: window)
        } else {
            //If there is no ABI posted on etherscan.
            let contractAbi = self.model.getContractABI(contractAddress: contractAddress)
            self.showArbitratySendingScreen(data: data, params: params,
                                            contractAddress: contractAddress,
                                            contractAbi: contractAbi,
                                            methodName: methodName,
                                            options: options,
                                            usingWindow: window)
        }
    }
    
    public func showArbitratySendingScreen(data: [AnyObject],
                                           params: [Parameter],
                                           contractAddress: EthereumAddress,
                                           contractAbi: String,
                                           methodName: String,
                                           options: TransactionOptions,
                                           usingWindow window: UIWindow) {
        guard let wallet = CurrentWallet.currentWallet else {return}
        if let tx = try? wallet.prepareWriteContractTx(contractABI: contractAbi,
                                                       contractAddress: contractAddress.address,
                                                       contractMethod: methodName,
                                                       parameters: data) {
            //TODO
//            let controller = SendArbitraryTransactionViewController(
//                params: params,
//                transactionInfo:
//                WriteTransactionInfo(contractAddress: contractAddress.address,
//                                     writeTransaction: tx,
//                                     methodName: methodName))
//            self.showController(controller,
//                                window: window)
        } else {
            //TODO
//            let controller = AppController().goToApp()
//            self.showController(controller,
//                                window: window)
//            Alerts().showErrorAlert(for: controller,
//                                    error: Errors.CommonErrors.unknown,
//                                    completion: nil)
        }
    }
    private func showController(_ controller: UIViewController, window: UIWindow) {
        DispatchQueue.main.async {
            window.rootViewController = controller
            window.makeKeyAndVisible()
        }
    }
}
