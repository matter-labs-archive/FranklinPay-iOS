//
//  EIP67CodeGenerator.swift
//  web3swift
//
//  Created by Alexander Vlasov on 09.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import CoreImage
import BigInt
import CryptoSwift


extension Web3 {

    public struct EIP67Code {
        public var address: EthereumAddress
        public var gasLimit: BigUInt?
        public var amount: BigUInt?
        public var data: DataType?
        
        public enum DataType {
            case data(Data)
            case function(Function)
        }
        public struct Function {
            public var method: String
            public var parameters: [(ABIv2.Element.ParameterType, AnyObject)]
            
            public func toString() -> String? {
                let encoding = method + "(" + parameters.map({ (el) -> String in
                    if let string = el.1 as? String {
                        return el.0.abiRepresentation + " " + string
                    } else if let number = el.1 as? BigUInt {
                        return el.0.abiRepresentation + " " + String(number, radix: 10)
                    } else if let number = el.1 as? BigInt {
                        return el.0.abiRepresentation + " " + String(number, radix: 10)
                    } else if let data = el.1 as? Data {
                        return el.0.abiRepresentation + " " + data.toHexString().addHexPrefix()
                    }
                    return ""
                }).joined(separator: ", ") + ")"
                return encoding
            }
        }
        
        public init (address : EthereumAddress) {
            self.address = address
        }
        
        public init? (address : String) {
            guard let addr = EthereumAddress(address) else {return nil}
            self.address = addr
        }
        
        public func toString() -> String {
            var urlComponents = URLComponents()
            let mainPart = "ethereum:"+self.address.address.lowercased()
            var queryItems = [URLQueryItem]()
            if let amount = self.amount {
                queryItems.append(URLQueryItem(name: "value", value: String(amount, radix: 10)))
            }
            if let gasLimit = self.gasLimit {
                queryItems.append(URLQueryItem(name: "gas", value: String(gasLimit, radix: 10)))
            }
            if let data = self.data {
                switch data {
                case .data(let d):
                    queryItems.append(URLQueryItem(name: "data", value: d.toHexString().addHexPrefix()))
                case .function(let f):
                    if let enc = f.toString() {
                        queryItems.append(URLQueryItem(name: "function", value: enc))
                    }
                }
            }
            urlComponents.queryItems = queryItems
            if let url = urlComponents.url {
                return mainPart + url.absoluteString
            }
            return mainPart
        }
        
        public func toImage(scale: Double = 1.0) -> CIImage {
            return EIP67CodeGenerator.createImage(from: self, scale: scale)
        }
    }

    public struct EIP67CodeGenerator {
        
        public static func createImage(from: EIP67Code, scale: Double = 1.0) -> CIImage {
            guard let string = from.toString().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {return CIImage()}
            guard let data = string.data(using: .utf8, allowLossyConversion: false) else {return CIImage()}
            let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: ["inputMessage" : data, "inputCorrectionLevel":"L"])
            guard var image = filter?.outputImage else {return CIImage()}
            let transformation = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
            image = image.transformed(by: transformation)
            return image
        }
    }

    public struct EIP67CodeParser {
        public static func parse(_ data: Data) -> EIP67Code? {
            guard let string = String(data: data, encoding: .utf8) else {return nil}
            return parse(string)
        }
        
        public static func parse(_ string: String) -> EIP67Code? {
            guard string.hasPrefix("ethereum:") else {return nil}
            let striped = string.components(separatedBy: "ethereum:")
            guard striped.count == 2 else {return nil}
            guard let encoding = striped[1].removingPercentEncoding else {return nil}
            guard let url = URL.init(string: encoding) else {return nil}
            guard let address = EthereumAddress(url.lastPathComponent) else {return nil}
            var code = EIP67Code(address: address)
            guard let components = URLComponents(string: encoding)?.queryItems else {return code}
            for comp in components {
                switch comp.name {
                case "value":
                    guard let value = comp.value else {return nil}
                    guard let val = BigUInt(value, radix: 10) else {return nil}
                    code.amount = val
                case "gas":
                    guard let value = comp.value else {return nil}
                    guard let val = BigUInt(value, radix: 10) else {return nil}
                    code.gasLimit = val
                case "data":
                    guard let value = comp.value else {return nil}
                    guard let data = Data.fromHex(value) else {return nil}
                    code.data = EIP67Code.DataType.data(data)
                case "function":
                    continue
                default:
                    continue
                }
            }
            return code
        }
    }
}


extension Web3 {
    
    //    request                 = "ethereum" ":" [ "pay-" ]target_address [ "@" chain_id ] [ "/" function_name ] [ "?" parameters ]
    //    target_address          = ethereum_address
    //    chain_id                = 1*DIGIT
    //    function_name           = STRING
    //    ethereum_address        = ( "0x" 40*40HEXDIG ) / ENS_NAME
    //    parameters              = parameter *( "&" parameter )
    //    parameter               = key "=" value
    //    key                     = "value" / "gas" / "gasLimit" / "gasPrice" / TYPE
    //    value                   = number / ethereum_address / STRING
    //    number                  = [ "-" / "+" ] *DIGIT [ "." 1*DIGIT ] [ ( "e" / "E" ) [ 1*DIGIT ] [ "+" UNIT ]
    
    public struct EIP681Code {
        public struct EIP681Parameter {
            public var type: ABIv2.Element.ParameterType
            public var value: AnyObject
        }
        public var isPayRequest: Bool
        public var targetAddress: TargetAddress
        public var chainID: BigUInt?
        public var functionName: String?
        public var parameters: [EIP681Parameter] = [EIP681Parameter]()
        public var params: [(String, String)] = []
        public var gasLimit: BigUInt?
        public var gasPrice: BigUInt?
        public var amount: BigUInt?
        public var function: ABIv2.Element.Function?
        
        public enum TargetAddress {
            case ethereumAddress(EthereumAddress)
            case ensAddress(String)
            public init(_ string: String) {
                if let ethereumAddress = EthereumAddress(string) {
                    self = TargetAddress.ethereumAddress(ethereumAddress)
                } else {
                    self = TargetAddress.ensAddress(string)
                }
            }
        }
        
        public init(_ targetAddress: TargetAddress, isPayRequest: Bool = false) {
            self.isPayRequest = isPayRequest
            self.targetAddress = targetAddress
        }
        
        //        public struct Function {
        //            public var method: String
        //            public var parameters: [(ABIv2.Element.ParameterType, AnyObject)]
        //
        //            public func toString() -> String? {
        //                let encoding = method + "(" + parameters.map({ (el) -> String in
        //                    if let string = el.1 as? String {
        //                        return el.0.abiRepresentation + " " + string
        //                    } else if let number = el.1 as? BigUInt {
        //                        return el.0.abiRepresentation + " " + String(number, radix: 10)
        //                    } else if let number = el.1 as? BigInt {
        //                        return el.0.abiRepresentation + " " + String(number, radix: 10)
        //                    } else if let data = el.1 as? Data {
        //                        return el.0.abiRepresentation + " " + data.toHexString().addHexPrefix()
        //                    }
        //                    return ""
        //                }).joined(separator: ", ") + ")"
        //                return encoding
        //            }
        //        }
    }
    
    public struct EIP681CodeParser {
        //        static var addressRegex = "^(pay-)?([0-9a-zA-Z]+)(@[0-9]+)?"
        static var addressRegex = "^(pay-)?([0-9a-zA-Z]+)(@[0-9]+)?\\/?(.*)?$"
        
        public static func parse(_ data: Data) -> EIP681Code? {
            guard let string = String(data: data, encoding: .utf8) else {return nil}
            return parse(string)
        }
        
        public static func parse(_ string: String) -> EIP681Code? {
            guard string.hasPrefix("ethereum:") else {return nil}
            let striped = string.components(separatedBy: "ethereum:")
            guard striped.count == 2 else {return nil}
            guard let encoding = striped[1].removingPercentEncoding else {return nil}
            //            guard let url = URL.init(string: encoding) else {return nil}
            let matcher = try! NSRegularExpression(pattern: addressRegex, options: NSRegularExpression.Options.dotMatchesLineSeparators)
            let match = matcher.matches(in: encoding, options: NSRegularExpression.MatchingOptions.anchored, range: encoding.fullNSRange)
            guard match.count == 1 else {return nil}
            guard match[0].numberOfRanges == 5 else {return nil}
            var addressString: String? = nil
            var chainIDString: String? = nil
            var tail: String? = nil
            //            if let payModifierRange = Range(match[0].range(at: 1), in: encoding) {
            //                let payModifierString = String(encoding[payModifierRange])
            //                print(payModifierString)
            //            }
            if  let addressRange = Range(match[0].range(at: 2), in: encoding) {
                addressString = String(encoding[addressRange])
            }
            if  let chainIDRange = Range(match[0].range(at: 3), in: encoding) {
                chainIDString = String(encoding[chainIDRange])
            }
            if  let tailRange = Range(match[0].range(at: 4), in: encoding) {
                tail = String(encoding[tailRange])
            }
            guard let address = addressString else {return nil}
            let targetAddress = EIP681Code.TargetAddress(address)
            
            var code = EIP681Code(targetAddress)
            if chainIDString != nil {
                code.chainID = BigUInt(chainIDString!)
            }
            if tail == nil {
                return code
            }
            guard let components = URLComponents(string: tail!) else {return code}
            if components.path == "" {
                code.isPayRequest = true
            } else {
                code.functionName = components.path
            }
            guard let queryItems = components.queryItems else {return code}
            var inputNumber: Int = 0
            var inputs = [ABIv2.Element.InOut]()
            for comp in queryItems {
                if let inputType = try? ABIv2TypeParser.parseTypeString(comp.name) {
                    guard let value = comp.value else {continue}
                    var nativeValue: AnyObject? = nil
                    switch inputType {
                    case .address:
                        let val = EIP681Code.TargetAddress(value)
                        guard case .ethereumAddress(let value1) = val else { return nil }
                        nativeValue = value1 as AnyObject
                    case .uint(bits: _):
                        if let val = BigUInt(value, radix: 10) {
                            nativeValue = val as AnyObject
                        } else if let val = BigUInt(value.stripHexPrefix(), radix: 16) {
                            nativeValue = val as AnyObject
                        }
                    case .string:
                        nativeValue = value as AnyObject
                    default:
                        continue
                    }
                    if nativeValue != nil {
                        inputs.append(ABIv2.Element.InOut(name: String(inputNumber), type: inputType))
                        code.parameters.append(EIP681Code.EIP681Parameter(type: inputType, value: nativeValue!))
                        code.params.append((inputType.abiRepresentation, value))
                        inputNumber = inputNumber + 1
                    }
                } else {
                    switch comp.name {
                    case "value":
                        guard let value = comp.value else {return nil}
                        guard let val = BigUInt(value, radix: 10) else {return nil}
                        code.amount = val
                    case "gas":
                        guard let value = comp.value else {return nil}
                        guard let val = BigUInt(value, radix: 10) else {return nil}
                        code.gasLimit = val
                    case "gasLimit":
                        guard let value = comp.value else {return nil}
                        guard let val = BigUInt(value, radix: 10) else {return nil}
                        code.gasLimit = val
                    case "gasPrice":
                        guard let value = comp.value else {return nil}
                        guard let val = BigUInt(value, radix: 10) else {return nil}
                        code.gasPrice = val
                    default:
                        continue
                    }
                }
            }
            
            if code.functionName != nil {
                let functionEncoding = ABIv2.Element.Function(name: code.functionName!, inputs: inputs, outputs: [ABIv2.Element.InOut](), constant: false, payable: code.amount != nil)
                code.function = functionEncoding
            }
            
            print(code)
            return code
        }
    }
}

public struct NameHash {
    public static func normalizeDomainName(_ domain: String) -> String? {
        // TODO use ICU4C library later for domain name normalization, althoug f**k it for now, it's few megabytes large piece
        let normalized = domain.lowercased()
        return normalized
    }
    
    public static func nameHash(_ domain: String) -> Data? {
        guard let normalized = NameHash.normalizeDomainName(domain) else {return nil}
        return namehash(normalized)
    }
    
    static func namehash(_ name: String) -> Data? {
        if name == "" {
            return Data(repeating: 0, count: 32)
        }
        let parts = name.split(separator: ".")
        guard parts.count > 0 else {
            return nil
        }
        guard let lowerLevel = parts.first else {
            return nil
        }
        var remainder = ""
        if parts.count > 1 {
            remainder = parts[1 ..< parts.count].joined(separator: ".")
        }
        // TODO here some better normalization can happen
        var hashData = Data()
        guard let remainderHash = namehash(remainder) else {
            return nil
        }
        guard let labelData = lowerLevel.data(using: .utf8) else {
            return nil
        }
        hashData.append(remainderHash)
        hashData.append(labelData.sha3(.keccak256))
        let hash = hashData.sha3(.keccak256)
        print(name)
        print(hash.toHexString())
        return hash
    }
}

