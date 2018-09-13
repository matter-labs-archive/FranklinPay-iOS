//
//  TransactionsService.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

protocol ITransactionsService {
    
    func prepareTransactionToContract(data: [AnyObject],
                                      contractAbi: String,
                                      contractAddress: String,
                                      method: String,
                                      predefinedOptions: Web3Options?,
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
                        with password: String?,
                        options: Web3Options?,
                        completion: @escaping (Result<TransactionSendingResult>) -> Void)
    
    func sendToken(transaction: TransactionIntermediate,
                   with password: String?,
                   options: Web3Options?,
                   completion: @escaping (Result<TransactionSendingResult>) -> Void)
    
    func getDataForTransaction(dict: [String:Any]) -> (transaction: TransactionIntermediate,
        options: Web3Options)
    
}

class TransactionsService: ITransactionsService {
    
    static let keyservice = KeysService()
    
    public func prepareTransactionToContract(data: [AnyObject],
                                             contractAbi: String,
                                             contractAddress: String,
                                             method: String,
                                             predefinedOptions: Web3Options? = nil,
                                             completion: @escaping (Result<TransactionIntermediate>) -> Void) {
        let wallet = TransactionsService.keyservice.selectedWallet()
        guard let address = wallet?.address else { return }
        let ethAddressFrom = EthereumAddress(address)
        let ethContractAddress = EthereumAddress(contractAddress)!
        
        let web3 = CurrentWeb.currentWeb ?? Web3.InfuraMainnetWeb3()
        web3.addKeystoreManager(TransactionsService.keyservice.keystoreManager())
        var options = predefinedOptions ?? Web3Options.defaultOptions()
        options.from = ethAddressFrom
        options.to = ethContractAddress
        options.value = options.value ?? 0
        guard let contract = web3.contract(contractAbi,
                                           at: ethContractAddress,
                                           abiVersion: 2) else {
                                            return
                                                DispatchQueue.main.async {
                                                    completion(Result.Error(TransactionErrors.init(rawValue: "Can not create a contract with given abi and address.")!))
                                            }
        }
        guard let gasPrice = web3.eth.getGasPrice().value else { return }
        options.gasPrice = predefinedOptions?.gasPrice ?? gasPrice
        guard let transaction = contract.method(method,
                                                parameters: data,
                                                options: options) else { return }
        guard case .success(let estimate) = transaction.estimateGas(options: options) else {
            DispatchQueue.main.async {
                completion(Result.Error(TransactionErrors.PreparingError))
            }
            return
        }
        print("estimated cost: \(estimate)")
        DispatchQueue.main.async {
            completion(Result.Success(transaction))
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
            
            
            let web3 = web3swift.web3(provider: InfuraProvider(CurrentNetwork.currentNetwork ?? Networks.Mainnet)!)
            web3.addKeystoreManager(KeysService().keystoreManager())
            
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
            
            let web3 = web3swift.web3(provider: InfuraProvider(CurrentNetwork.currentNetwork ?? Networks.Mainnet)!)
            web3.addKeystoreManager(KeysService().keystoreManager())
            
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
            //options.gasLimit = estimatedGas
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
                               with password: String? = "BANKEXFOUNDATION",
                               options: Web3Options? = nil,
                               completion: @escaping (Result<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password ?? "BANKEXFOUNDATION",
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
                          with password: String? = "BANKEXFOUNDATION",
                          options: Web3Options? = nil,
                          completion: @escaping (Result<TransactionSendingResult>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = transaction.send(password: password ?? "BANKEXFOUNDATION",
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
    
    public func getDataForTransaction(dict: [String:Any]) -> (transaction: TransactionIntermediate, options: Web3Options) {
        let token  = CurrentToken.currentToken
        let model = ETHTransactionModel(from: dict["fromAddress"] as! String, to: dict["toAddress"] as! String, amount: dict["amount"] as! String, date: Date(), token: token!, key: KeysService().selectedKey()!, isPending: true)
        var options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(dict["gasLimit"] as! String)
        let gp = BigUInt(Double(dict["gasPrice"] as! String)! * pow(10, 9))
        options.gasPrice = gp
        let transaction = dict["transaction"] as! TransactionIntermediate
        options.from = transaction.options?.from
        options.to = transaction.options?.to
        options.value = transaction.options?.value
        return (transaction: transaction, options: options)
    }
}

enum TransactionErrors: String, Error {
    case PreparingError = "Couldn't prepare transaction with such parameters"
}

