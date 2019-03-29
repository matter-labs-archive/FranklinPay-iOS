//
//  WalletBlock.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt

protocol IWalletBlock {
//    func getBlockNumber(_ web3instance: web3?) throws -> BigUInt
//    func getBlock(_ web3instance: web3?) throws -> String
}

extension Wallet: IWalletBlock {
//    public func getBlockNumber(_ web3instance: web3? = nil) throws -> BigUInt {
//        guard let web3 = web3instance ?? self.web3Instance else {
//            throw Web3Error.walletError
//        }
//        if web3instance != nil {
//            web3.addKeystoreManager(self.keystoreManager)
//        }
//        do {
//            let blockNumber = try web3.eth.getBlockNumber()
//            return blockNumber
//        } catch let error {
//            throw error
//        }
//    }
//
//    public func getBlock(_ web3instance: web3? = nil) throws -> String {
//        guard let web3 = web3instance ?? self.web3Instance else {
//            throw Web3Error.walletError
//        }
//        if web3instance != nil {
//            web3.addKeystoreManager(self.keystoreManager)
//        }
//        do {
//            let block = try web3.eth.getBlock()
//            return block
//        } catch let error {
//            throw error
//        }
//    }
}
