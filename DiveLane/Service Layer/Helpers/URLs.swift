//
//  URL.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress
import Web3swift

public struct URLs {
    static let pricesFromCryptocompare = "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=%@&tsyms=USD"
    static let downloadTokensList = "https://raw.githubusercontent.com/kvhnuke/etherwallet/mercury/app/scripts/tokens/ethTokens.json"
    
    public func getContractURL(for address: String) -> String {
        return "https://api-rinkeby.etherscan.io/api?module=contract&action=getabi&address=\(address)&apikey=YourApiKeyToken"
    }
    
    public func getEtherscanURL(for type: TransactionType, address: String, networkId: Int64) -> URL? {
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
}
