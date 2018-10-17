//
//  Web3Service.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

protocol IWeb3SwiftService {
    func sendTransaction(transaction: TransactionIntermediate, password: String, completion: @escaping (Result<TransactionSendingResult>) -> Void)
    func getETHbalance(for wallet: KeyWalletModel, completion: @escaping (String?, Error?) -> Void)
    func getETHbalance(forAddress address: String, completion: @escaping (String?, Error?) -> Void)
    func getERCBalance(for token: String,
                       address: String,
                       completion: @escaping (String?, Error?) -> Void)
    func defaultOptions() -> Web3Options
    func contract(for address: String) -> web3.web3contract?
}

class Web3SwiftService: IWeb3SwiftService {

    static var web3instance: web3 {
        //let web3 = Web3.InfuraMainnetWeb3()
        let web3 = CurrentWeb.currentWeb ?? Web3.InfuraMainnetWeb3()
        web3.addKeystoreManager(KeysService().keystoreManager())
        return web3
    }

    static var currentAddress: EthereumAddress? {
        let wallet = KeysService().selectedWallet()
        guard let address = wallet?.address else {
            return nil
        }
        let ethAddressFrom = EthereumAddress(address)
        return ethAddressFrom
    }

    // MARK: - Send transaction
    public func sendTransaction(transaction: TransactionIntermediate, password: String, completion: @escaping (Result<TransactionSendingResult>) -> Void) {
        DispatchQueue.global().async {
            //sending
            let result = transaction.send(password: password, options: nil)
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    completion(Result.Success(value))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(Result.Error(error))
                }
            }
        }
    }

    // MARK: - Get ETH balance
    public func getETHbalance(for wallet: KeyWalletModel, completion: @escaping (String?, Error?) -> Void) {
        DispatchQueue.global().async {
            let address = wallet.address
            let ETHaddress = EthereumAddress(address)!
            let web3Main = CurrentWeb.currentWeb ?? Web3.InfuraMainnetWeb3()
            let balanceResult = web3Main.eth.getBalance(address: ETHaddress)
            guard case .success(let balance) = balanceResult else {
                DispatchQueue.main.async {
                    completion(nil, balanceResult.error)
                }
                return
            }
            DispatchQueue.main.async {
                let ethUnits = Web3Utils.formatToEthereumUnits(balance,
                        toUnits: .eth,
                        decimals: 6,
                        decimalSeparator: ".")
                completion(ethUnits, nil)
            }
        }
    }

    public func getETHbalance(forAddress address: String, completion: @escaping (String?, Error?) -> Void) {
        DispatchQueue.global().async {
            let ETHaddress = EthereumAddress(address)!
            let web3Main = CurrentWeb.currentWeb ?? Web3.InfuraMainnetWeb3()
            let balanceResult = web3Main.eth.getBalance(address: ETHaddress)
            guard case .success(let balance) = balanceResult else {
                DispatchQueue.main.async {
                    completion(nil, balanceResult.error)
                }
                return
            }
            DispatchQueue.main.async {
                let ethUnits = Web3Utils.formatToEthereumUnits(balance,
                        toUnits: .eth,
                        decimals: 6,
                        decimalSeparator: ".")
                completion(ethUnits, nil)
            }
        }
    }

    // MARK: - Get token balance
    public func getERCBalance(for token: String,
                              address: String,
                              completion: @escaping (String?, Error?) -> Void) {
        DispatchQueue.global().async {

            _ = web3swift.web3(provider: InfuraProvider(CurrentNetwork.currentNetwork ?? Networks.Mainnet)!)
            guard let ethAddress = EthereumAddress(address) else {
                DispatchQueue.main.async {
                    completion(nil, BalanceError.wrongAddress)
                }
                return
            }
            let contract = self.contract(for: token)
            let parameters = [ethAddress]
            let transaction = contract?.method("balanceOf",
                    parameters: parameters as [AnyObject],
                    options: self.defaultOptions())
            let balance = transaction?.call(options: self.defaultOptions())

            DispatchQueue.main.async {
                if let balance = balance?.value?["balance"] as? BigUInt {
                    let ethUnits = Web3Utils.formatToEthereumUnits(balance,
                            toUnits: .eth,
                            decimals: 6,
                            decimalSeparator: ".")
                    completion(ethUnits, nil)
                } else {
                    DispatchQueue.main.async {
                        completion(nil, BalanceError.cantGetBalance)
                    }
                }

            }
        }
    }

    public func contract(for address: String) -> web3.web3contract? {
        let web3 = web3swift.web3(provider: InfuraProvider(CurrentNetwork.currentNetwork ?? Networks.Mainnet)!)
        web3.addKeystoreManager(KeysService().keystoreManager())
        guard let ethAddress = EthereumAddress(address) else {
            return nil
        }
        return web3.contract(Web3.Utils.erc20ABI, at: ethAddress)
        /*("0x7EA2Df0F49D1cf7cb3a328f0038822B08AEB0aC1")) 0xe41d2489571d322189246dafa5ebde1f4699f498
         0x6ff6c0ff1d68b964901f986d4c9fa3ac68346570 - zrx on kovan
         0x5b0095100c1ce9736cdcb449a3199935a545ccce*/
    }

    public func defaultOptions() -> Web3Options {
        var options = Web3Options.defaultOptions()
        //        options.gasLimit = BigUInt(250000)
        //        options.gasPrice = BigUInt(250000000)
        options.from = EthereumAddress((KeysService().selectedWallet()?.address)!)
        return options
    }

}
