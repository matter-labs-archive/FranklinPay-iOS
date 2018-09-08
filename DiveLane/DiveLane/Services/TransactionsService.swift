//
//  TransactionsService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import BigInt

protocol ITransactionsService {
    
    func prepareTransactionToContract(data: [Any],
                                      contractAbi: String,
                                      contractAddress: String,
                                      method: String,
                                      amountString: String,
                                      gasLimit: BigUInt,
                                      completion: @escaping (Result<TransactionIntermediate>) -> Void)
    
    func prepareTransactionForSendingEther(destinationAddressString: String,
                                           amountString: String,
                                           gasLimit: BigUInt,
                                           completion: @escaping (Result<TransactionIntermediate>) -> Void)
    
    func prepareTransactionForSendingERC(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: BigUInt,
                                      tokenAddress token: String,
                                      completion: @escaping (Result<TransactionIntermediate>) -> Void)
    
    func sendToContract(transaction: TransactionIntermediate,
                      with password: String,
                      options: Web3Options?,
                      completion: @escaping (Result<TransactionSendingResult>) -> Void)
    
    func sendToken(transaction: TransactionIntermediate,
                   with password: String,
                   options: Web3Options?,
                   completion: @escaping (Result<TransactionSendingResult>) -> Void)
    
}

class TransactionsService: ITransactionsService {
    
    static let keyservice = KeysService()
    
    public func prepareTransactionToContract(data: [Any],
                                      contractAbi: String,
                                      contractAddress: String,
                                      method: String,
                                      amountString: String,
                                      gasLimit: BigUInt = 27500,
                                      completion: @escaping (Result<TransactionIntermediate>) -> Void) {
        DispatchQueue.global().async {
            let wallet = TransactionsService.keyservice.selectedWallet()
            guard let address = wallet?.address else { return }
            let ethAddressFrom = EthereumAddress(address)
            let ethContractAddress = EthereumAddress(contractAddress)!
            
            guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.invalidAmountFormat))
                }
                return
            }
            
            let web3 = Web3.InfuraMainnetWeb3()
            web3.addKeystoreManager(TransactionsService.keyservice.keystoreManager())
            
            var options = Web3Options.defaultOptions()
            options.from = ethAddressFrom
            options.value = amount
            guard let contract = web3.contract(contractAbi,
                                               at: ethContractAddress,
                                               abiVersion: 2) else { return }
            guard let gasPrice = web3.eth.getGasPrice().value else { return }
            options.gasPrice = gasPrice
            options.gasLimit = gasLimit
            guard let transaction = contract.method(method,
                                                    parameters: data as [AnyObject],
                                                    options: options) else { return }
            guard case .success(let estimate) = transaction.estimateGas(options: options) else {return}
            print("estimated cost: \(estimate)")
            DispatchQueue.main.async {
                completion(Result.Success(transaction))
            }
        }
    }
    
    public func prepareTransactionForSendingEther(destinationAddressString: String,
                                           amountString: String,
                                           gasLimit: BigUInt,
                                           completion: @escaping (Result<TransactionIntermediate>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.invalidDestinationAddress))
                }
                return
            }
            guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.invalidAmountFormat))
                }
                return
            }
            guard let selectedKey = KeysService().selectedWallet()?.address else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.noAvailableKeys))
                }
                return
            }
            
            let web3 = Web3SwiftService.web3instance
            let ethAddressFrom = EthereumAddress(selectedKey)
            var options = Web3Options.defaultOptions()
            //            options.gasLimit = BigUInt(gasLimit)
            options.from = ethAddressFrom
            options.value = BigUInt(amount)
            guard let contract = web3.contract(Web3.Utils.coldWalletABI, at: destinationEthAddress) else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.contractLoadingError))
                }
                return
            }
            
            guard let estimatedGas = contract.method(options: options)?.estimateGas(options: nil).value else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.retrievingEstimatedGasError))
                }
                return
            }
            options.gasLimit = estimatedGas
            guard let gasPrice = web3.eth.getGasPrice().value else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.retrievingGasPriceError))
                }
                return
            }
            options.gasPrice = gasPrice
            guard let transaction = contract.method(options: options) else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.createTransactionIssue))
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(Result.Success(transaction))
            }
            
        }
    }
    
    public func prepareTransactionForSendingERC(destinationAddressString: String,
                                      amountString: String,
                                      gasLimit: BigUInt,
                                      tokenAddress token: String,
                                      completion: @escaping (Result<TransactionIntermediate>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let destinationEthAddress = EthereumAddress(destinationAddressString) else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.invalidDestinationAddress))
                }
                return
            }
            guard let amount = Web3.Utils.parseToBigUInt(amountString, units: .eth) else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.invalidAmountFormat))
                }
                return
            }
            
            let web3 = Web3SwiftService.web3instance
            let contract = self.contract(for: token, web3: web3)
            var options = Web3Options.defaultOptions()
            
            guard let tokenAddress = EthereumAddress(token),
                let fromAddress = Web3SwiftService.currentAddress,
                let intermediate = web3.eth.sendERC20tokensWithNaturalUnits(
                    tokenAddress: tokenAddress,
                    from: fromAddress,
                    to: destinationEthAddress,
                    amount: amountString) else {
                        DispatchQueue.main.async {
                            completion(Result.Error(SendErrors.createTransactionIssue))
                        }
                        return
            }
            DispatchQueue.main.async {
                completion(Result.Success(intermediate))
            }
            
            return
            //MARK: - Just to check that everything is all right
            guard let estimatedGas = contract?.method(options: options)?.estimateGas(options: options).value else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.retrievingEstimatedGasError))
                }
                return
            }
            guard let gasPrice = web3.eth.getGasPrice().value else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.retrievingGasPriceError))
                }
                return
            }
            
            options.from = Web3SwiftService.currentAddress
            options.gasPrice = gasPrice
            options.gasLimit = estimatedGas
            options.value = 0
            options.to = EthereumAddress(token)
            let parameters = [destinationEthAddress,
                              amount] as [Any]
            guard let transaction = contract?.method("transfer",
                                                     parameters: parameters as [AnyObject],
                                                     options: options) else {
                                                        DispatchQueue.main.async {
                                                            completion(Result.Error(SendErrors.createTransactionIssue))
                                                        }
                                                        
                                                        return
            }
            DispatchQueue.main.async {
                completion(Result.Success(transaction))
            }
            
            return
        }
    }
    
    public func sendToContract(transaction: TransactionIntermediate,
                      with password: String,
                      options: Web3Options? = nil,
                      completion: @escaping (Result<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password,
                                          options: transaction.options)
            if let error = result.error {
                DispatchQueue.main.async {
                    completion(Result.Error(error))
                }
                return
            }
            guard let value = result.value else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.emptyResult))
                }
                return
            }
            DispatchQueue.main.async {
                completion(Result.Success(value))
            }
        }
    }
    
    public func sendToken(transaction: TransactionIntermediate,
                   with password: String,
                   options: Web3Options? = nil,
                   completion: @escaping (Result<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password,
                                          options: options)
            if let error = result.error {
                DispatchQueue.main.async {
                    completion(Result.Error(error))
                }
                return
            }
            guard let value = result.value else {
                DispatchQueue.main.async {
                    completion(Result.Error(SendErrors.emptyResult))
                }
                return
            }
            DispatchQueue.main.async {
                completion(Result.Success(value))
            }
        }
    }
    
    
    private func contract(for address: String, web3: web3) -> web3.web3contract? {
        guard let ethAddress = EthereumAddress(address) else {
            return nil
        }
        return web3.contract(Web3.Utils.erc20ABI, at: ethAddress)
    }
}

