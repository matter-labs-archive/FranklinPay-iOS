//
//  PlasmaParser.swift
//  DiveLane
//
//  Created by Anton Grigorev on 07/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress

/// A Plasma URL Parser
public struct PlasmaParser {
    
    static let plasmaParser = PlasmaParser()
    
    static var addressRegex = "^(pay-)?([0-9a-zA-Z.]+)(@[0-9]+)?\\/?(.*)?$"
    
    /// Parse data to PlasmaCode
    ///
    /// - Parameter data: Data to parse
    /// - Returns: PlasmaCode optional
    public static func parse(_ data: Data) -> PlasmaCode? {
        guard let string = String(data: data, encoding: .utf8) else {return nil}
        return parse(string)
    }
    
    /// Sets target address
    ///
    /// - Parameter address: target address in String
    /// - Returns: EthereumAddress representation for target address
    public func setTargetAddress(address: String) -> EthereumAddress {
        return EthereumAddress(address)!
    }
    
    /// Parse data to PlasmaCode
    ///
    /// - Parameter string: String to parse
    /// - Returns: PlasmaCode optional
    public static func parse(_ string: String) -> PlasmaCode? {
        guard string.hasPrefix("plasma:") else {return nil}
        let striped = string.components(separatedBy: "plasma:")
        guard striped.count == 2 else {return nil}
        guard let encoding = striped[1].removingPercentEncoding else {return nil}
        guard let matcher = try? NSRegularExpression(pattern: addressRegex, options: NSRegularExpression.Options.dotMatchesLineSeparators) else {return nil}
        let match = matcher.matches(in: encoding, options: NSRegularExpression.MatchingOptions.anchored, range: encoding.fullNSRange)
        guard match.count == 1 else {return nil}
        guard match[0].numberOfRanges == 5 else {return nil}
        var addressString: String?
        var tail: String?
        
        if  let addressRange = Range(match[0].range(at: 2), in: encoding) {
            addressString = String(encoding[addressRange])
        }
        if  let tailRange = Range(match[0].range(at: 4), in: encoding) {
            tail = String(encoding[tailRange])
        }
        guard let address = addressString else {return nil}
        let targetAddress = plasmaParser.setTargetAddress(address: address)
        
        var code = PlasmaCode(targetAddress)
        if tail == nil {
            return code
        }
        guard let components = URLComponents(string: tail!) else {return code}
        if components.path == "split" {
            code.txType = .split
        } else if components.path == "fund" {
            code.txType = .fund
        }
        guard let queryItems = components.queryItems else {return code}
        for comp in queryItems {
            switch comp.name {
            case "chainId":
                guard let value = comp.value else {return nil}
                guard let val = BigUInt(value) else {return nil}
                code.chainID = val
            case "value":
                guard let value = comp.value else {return nil}
                code.amount = value
            default:
                continue
            }
        }
        
        print(code)
        return code
    }
}
