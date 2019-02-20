////
////  BuffiParser.swift
////  Franklin
////
////  Created by Anton on 17/02/2019.
////  Copyright © 2019 Matter Inc. All rights reserved.
////
//
//import Foundation
//import BigInt
//import EthereumAddress
//
//public struct BuffiCode {
//    public var targetAddress: EthereumAddress
//    public var count: BigUInt?
//    public var price: BigUInt?
//    
//    public init(_ targetAddress: EthereumAddress) {
//        self.targetAddress = targetAddress
//    }
//}
//
//public struct BuffiParser {
//    
//    static let buffiParser = BuffiParser()
//    
//    static var addressRegex = "^(pay-)?([0-9a-zA-Z.]+)(@[0-9]+)?\\/?(.*)?$"
//    
//    public static func parse(_ data: Data) -> BuffiCode? {
//        guard let string = String(data: data, encoding: .utf8) else {return nil}
//        return parse(string)
//    }
//    
//    public func setTargetAddress(address: String) -> EthereumAddress {
//        return EthereumAddress(address)!
//    }
//    
//    public static func parse(_ string: String) -> BuffiCode? {
//        guard string.hasPrefix("buffishop:") else {return nil}
//        let striped = string.components(separatedBy: "buffishop:")
//        guard striped.count == 2 else {return nil}
//        guard let encoding = striped[1].removingPercentEncoding else {return nil}
//        guard let matcher = try? NSRegularExpression(pattern: addressRegex, options: NSRegularExpression.Options.dotMatchesLineSeparators) else {return nil}
//        let match = matcher.matches(in: encoding, options: NSRegularExpression.MatchingOptions.anchored, range: encoding.fullNSRange)
//        guard match.count == 1 else {return nil}
//        guard match[0].numberOfRanges == 5 else {return nil}
//        var addressString: String?
//        var tail: String?
//        
//        if  let addressRange = Range(match[0].range(at: 2), in: encoding) {
//            addressString = String(encoding[addressRange])
//        }
//        if  let tailRange = Range(match[0].range(at: 4), in: encoding) {
//            tail = String(encoding[tailRange])
//        }
//        guard let address = addressString else {return nil}
//        let targetAddress = buffiParser.setTargetAddress(address: address)
//        
//        var code = BuffiCode(targetAddress)
//        if tail == nil {
//            return code
//        }
//        
//        guard let components = URLComponents(string: tail!) else {return code}
//        guard let queryItems = components.queryItems else {return code}
//        for comp in queryItems {
//            switch comp.name {
//            case "count":
//                guard let value = comp.value else {return nil}
//                guard let val = BigUInt(value) else {return nil}
//                code.count = val
//            case "price":
//                guard let value = comp.value else {return nil}
//                guard let val = BigUInt(value) else {return nil}
//                code.price = val
//            default:
//                continue
//            }
//        }
//        
//        print(code)
//        return code
//    }
//}
