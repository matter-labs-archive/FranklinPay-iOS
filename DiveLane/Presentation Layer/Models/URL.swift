//
//  URL.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

import web3swift

struct GenericParsedURL {
    var type: TransactionType
    var recieverAddress: EthereumAddress?
    var tokenAddress: EthereumAddress?
    var methodName: String?
    var amount: UInt64?
    var parameters: [Any]?
    var parametersView: [Parameter]?
    var contractAbi: String?
}

struct URLs {
    static let urlPricesFromCryptocompare = "https://min-api.cryptocompare.com/data/price?fsym=%@&tsyms=USD"
    static let urlDownloadTOkensList = "https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json"
}

func getURL(forContractAddress: String) -> String {
    return "https://api-rinkeby.etherscan.io/api?module=contract&action=getabi&address=\(forContractAddress)&apikey=YourApiKeyToken"
}

func getURL(forType type: TransactionType, address: String, networkId: Int64) -> URL? {
    var urlNetworkParameter: String
    switch networkId {
    case 1:
        urlNetworkParameter = ""
    case 3:
        urlNetworkParameter = "-ropsten"
    case 4:
        urlNetworkParameter = "-rinkeby"
    case 42:
        urlNetworkParameter = "-kovan"
    default:
        urlNetworkParameter = ""
    }
    
    var url: URL?
    switch type {
    case .custom:
        url = URL(string: "https://api\(urlNetworkParameter).etherscan.io/api?module=account&action=txlist&address=\(address)&startblock=0&endblock=99999999&sort=asc")
    case .arbitraryMethodWithParams:
        url = URL(string: "https://api\(urlNetworkParameter).etherscan.io/api?module=account&action=tokentx&address=\(address)&startblock=0&endblock=99999999&sort=asc")
        
    }
    return url
}
