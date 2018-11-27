//
//  AppControllerModel.swift
//  DiveLane
//
//  Created by NewUser on 27/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import BigInt

class EIP681Model {
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
    // MARK: - ENS parser, when PR to w3s will be approved
    public func getParsedAddress(targetAddress: Web3.EIP681Code.TargetAddress) -> EthereumAddress {
        switch targetAddress {
        case .ensAddress(let domain):
            return EthereumAddress(domain)!
        case .ethereumAddress(let address):
            return address
        }
    }
    // MARK: - This is a useless function, but should become useful sometimes.
    public func getContractABI(contractAddress: EthereumAddress) -> String {
        if contractAddress.address == "0xfa28ec7198028438514b49a3cf353bca5541ce1d" {
            return peepEthAbi
        } else {
            return peepEthAbi
        }
    }
}
