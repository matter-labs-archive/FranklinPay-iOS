//
//  ParserEIP.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import web3swift
import struct BigInt.BigUInt

class Parser {
    //Custom payment
    //ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359?value=2.014e18
    
    
    //ERC20 transfer
    //ethereum:0x45245bc59219eeaaf6cd3f382e078a461ff9de7b/transfer?address=0x6891dC3962e710f0ff711B9c6acc26133Fd35Cb4&uint256=1
    
    //Better than a regular
    func genericlyParseURLethereum(url: String) -> GenericParsedURL? {
        let splittedUrl = url.split(separator: "/")
        //Custom Transaction
        if splittedUrl.count == 1, let splittedUrl = splittedUrl.first {
            let oneMoreSplit = splittedUrl.split(separator: "?")
            guard let addressTo = oneMoreSplit.first else { return nil }
            guard let amountString = oneMoreSplit.last?.split(separator: "="), let leftParam = amountString.first, String(leftParam) == "value", let amount = amountString.last else { return nil }
            print(String(addressTo))
            guard let receiverAddress = EthereumAddress(String(addressTo)) else { return nil }
            //TODO: - Parse into BigUInt, could be e18 notations.
            guard let amountToSend = UInt64(String(amount)) else { return nil }
            return GenericParsedURL(type: .custom,recieverAddress: receiverAddress, tokenAddress: nil, methodName: nil, amount: amountToSend, parameters: nil, parametersView: nil, contractAbi: nil)
        } else if splittedUrl.count == 2 {
            //MARK: - Generic parser
            guard let tokenAddressString = splittedUrl.first, let tokenAddress = EthereumAddress(String(tokenAddressString)) else { return nil }
            guard let rightPart = splittedUrl.last else { return nil }
            let splitted = rightPart.split(separator: "?")
            if splitted.count == 2 {
                //TODO: - Here should be contract abi field parsed
                guard let methodName = splitted.first else { return nil }
                guard let right = splitted.last else { return nil }
                let splittedRight = right.split(separator: "&")
                var params = [Any]()
                var paramsView = [Parameter]()
                for el in splittedRight.map({String($0)}) {
                    let splittedParameters = el.split(separator: "=")
                    guard let value = splittedParameters.last else { return nil }
                    guard let type = splittedParameters.first else { return nil }
                    
                    print(value)
                    //TODO: - This is not good, probably not working
                    params.append(value as Any)
                    paramsView.append(Parameter(type: String(type), value: String(value)))
                }
                return GenericParsedURL(type: .arbitraryMethodWithParams,recieverAddress: nil, tokenAddress: tokenAddress, methodName: String(methodName), amount: nil, parameters: params, parametersView: paramsView, contractAbi: "")
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
