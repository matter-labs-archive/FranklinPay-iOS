//
//  PlasmaParserModel.swift
//  DiveLane
//
//  Created by Anton Grigorev on 07/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import Web3swift
import BigInt
import EthereumAddress

class PlasmaParserModel {
    // MARK: - Choose the right network, MAINNET by default, if no network provided.
    public func changeCurrentNetowrk(chainId: BigUInt?) {
        switch chainId {
        case 1?:
            CurrentNetwork.currentNetwork = Networks.Mainnet
        case 3?:
            CurrentNetwork.currentNetwork = Networks.Ropsten
        case 4?:
            CurrentNetwork.currentNetwork = Networks.Rinkeby
        case 42?:
            CurrentNetwork.currentNetwork = Networks.Kovan
        case .some(let value):
            CurrentNetwork.currentNetwork = Networks.Custom(networkID: value)
        default:
            CurrentNetwork.currentNetwork = Networks.Mainnet
        }
    }
}
