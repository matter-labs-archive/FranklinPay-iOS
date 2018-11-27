//
//  Web3Service.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import EthereumAddress
import BigInt

protocol IWeb3Service {
    func prepareSendEthTx(toAddress: EthereumAddress,
                          value: String,
                          gasLimit: TransactionOptions.GasLimitPolicy,
                          gasPrice: TransactionOptions.GasPricePolicy) throws -> WriteTransaction
    func prepareSendERC20Tx(tokenAddress: EthereumAddress,
                            toAddress: EthereumAddress,
                            tokenAmount: String,
                            gasLimit: TransactionOptions.GasLimitPolicy,
                            gasPrice: TransactionOptions.GasPricePolicy) throws -> WriteTransaction
    func prepareWriteContractTx(contractABI: String,
                                contractAddress: EthereumAddress,
                                contractMethod: String,
                                value: String,
                                gasLimit: TransactionOptions.GasLimitPolicy,
                                gasPrice: TransactionOptions.GasPricePolicy,
                                parameters: [AnyObject],
                                extraData: Data) throws -> WriteTransaction
    func prepareReadContractTx(contractABI: String,
                               contractAddress: EthereumAddress,
                               contractMethod: String,
                               gasLimit: TransactionOptions.GasLimitPolicy,
                               gasPrice: TransactionOptions.GasPricePolicy,
                               parameters: [AnyObject],
                               extraData: Data) throws -> ReadTransaction
    func sendTx(transaction: WriteTransaction,
                options: TransactionOptions?,
                password: String) throws -> TransactionSendingResult
    func callTx(transaction: ReadTransaction,
                options: TransactionOptions?) throws -> [String : Any]
    func getETHbalance(for wallet: KeyWalletModel) throws -> String
    func getERC20balance(for wallet: KeyWalletModel,
                         tokenAddress: EthereumAddress) throws -> String
}

public class Web3Service: IWeb3Service {
    
    private var web3Instance: web3 {
        let web3 = CurrentWeb.currentWeb
        web3.addKeystoreManager(KeysService().keystoreManager())
        return web3
    }
    
    private var currentAddress: EthereumAddress {
        let wallet = KeysService().selectedWallet()
        let address = wallet?.address
        let ethAddressFrom = EthereumAddress(address!)!
        return ethAddressFrom
    }
    
    private func defaultOptions() -> TransactionOptions {
        var options = TransactionOptions.defaultOptions
        let address = self.currentAddress
        options.from = address
        return options
    }
    
    public func prepareSendEthTx(toAddress: EthereumAddress,
                                 value: String = "0.0",
                                 gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                 gasPrice: TransactionOptions.GasPricePolicy = .automatic) throws -> WriteTransaction {
        guard let contract = web3Instance.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2) else {
            throw Web3Error.dataError
        }
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = defaultOptions()
        options.value = amount
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        guard let tx = contract.write("fallback",
                                      parameters: [AnyObject](),
                                      extraData: Data(),
                                      transactionOptions: options) else {
                                            throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func prepareSendERC20Tx(tokenAddress: EthereumAddress,
                                   toAddress: EthereumAddress,
                                   tokenAmount: String = "0.0",
                                   gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                   gasPrice: TransactionOptions.GasPricePolicy = .automatic) throws -> WriteTransaction {
        guard let contract = web3Instance.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2) else {
            throw Web3Error.dataError
        }
        let amount = Web3.Utils.parseToBigUInt(tokenAmount, units: .eth)
        var options = defaultOptions()
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        guard let tx = contract.write("transfer",
                                      parameters: [toAddress, amount] as [AnyObject],
                                      extraData: Data(),
                                      transactionOptions: options) else {
            throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func prepareWriteContractTx(contractABI: String,
                                      contractAddress: EthereumAddress,
                                      contractMethod: String,
                                      value: String = "0.0",
                                      gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                      gasPrice: TransactionOptions.GasPricePolicy = .automatic,
                                      parameters: [AnyObject] = [AnyObject](),
                                      extraData: Data = Data()) throws -> WriteTransaction {
        guard let contract = web3Instance.contract(contractABI, at: contractAddress, abiVersion: 2) else {
            throw Web3Error.dataError
        }
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        var options = defaultOptions()
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        options.value = amount
        guard let tx = contract.write(contractMethod,
                                      parameters: parameters,
                                      extraData: extraData,
                                      transactionOptions: options) else {
                                        throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func prepareReadContractTx(contractABI: String,
                                      contractAddress: EthereumAddress,
                                      contractMethod: String,
                                      gasLimit: TransactionOptions.GasLimitPolicy = .automatic,
                                      gasPrice: TransactionOptions.GasPricePolicy = .automatic,
                                      parameters: [AnyObject] = [AnyObject](),
                                      extraData: Data = Data()) throws -> ReadTransaction {
        guard let contract = web3Instance.contract(contractABI, at: contractAddress, abiVersion: 2) else {
            throw Web3Error.dataError
        }
        var options = defaultOptions()
        options.gasPrice = gasPrice
        options.gasLimit = gasLimit
        guard let tx = contract.read(contractMethod,
                                     parameters: parameters,
                                     extraData: extraData,
                                     transactionOptions: options) else {
                                        throw Web3Error.transactionSerializationError
        }
        return tx
    }
    
    public func sendTx(transaction: WriteTransaction,
                       options: TransactionOptions? = nil,
                       password: String) throws -> TransactionSendingResult {
        do {
            let txOptions = options ?? transaction.transactionOptions
            let result = try transaction.send(password: password, transactionOptions: txOptions)
            return result
        } catch let error{
            throw error
        }
    }
    
    public func callTx(transaction: ReadTransaction,
                       options: TransactionOptions? = nil) throws -> [String : Any] {
        do {
            let txOptions = options ?? transaction.transactionOptions
            let result = try transaction.call(transactionOptions: txOptions)
            return result
        } catch let error{
            throw error
        }
    }
    
    public func getETHbalance(for wallet: KeyWalletModel) throws -> String {
        do {
            guard let walletAddress = EthereumAddress(wallet.address) else {
                throw Web3Error.walletError
            }
            let web3 = self.web3Instance
            let balanceResult = try web3.eth.getBalance(address: walletAddress)
            guard let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3) else {
                throw Web3Error.dataError
            }
            return balanceString
        } catch let error{
            throw error
        }
    }
    
    public func getERC20balance(for wallet: KeyWalletModel,
                                tokenAddress: EthereumAddress) throws -> String {
        do {
            guard let walletAddress = EthereumAddress(wallet.address) else {
                throw Web3Error.walletError
            }
            let tx = try self.prepareReadContractTx(contractABI: Web3.Utils.erc20ABI,
                                                    contractAddress: tokenAddress,
                                                    contractMethod: "balanceOf",
                                                    gasLimit: .automatic,
                                                    gasPrice: .automatic,
                                                    parameters: [walletAddress] as [AnyObject],
                                                    extraData: Data())
            let tokenBalance = try self.callTx(transaction: tx)
            guard let balanceResult = tokenBalance["0"] as? BigUInt else {
                throw Web3Error.dataError
            }
            guard let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3) else {
                throw Web3Error.dataError
            }
            return balanceString
        } catch let error {
            throw error
        }
    }
}

