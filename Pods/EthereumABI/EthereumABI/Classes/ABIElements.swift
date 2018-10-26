//
//  Created by Alex Vlasov on 25/10/2018.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation
import BigInt

public extension ABI {
    // JSON Decoding
    public struct Input: Decodable {
        var name: String?
        var type: String
        var indexed: Bool?
        var components: [Input]?
    }
    
    public struct Output: Decodable {
        var name: String?
        var type: String
        var components: [Output]?
    }

    public struct Record: Decodable {
        var name: String?
        var type: String?
        var payable: Bool?
        var constant: Bool?
        var stateMutability: String?
        var inputs: [ABI.Input]?
        var outputs: [ABI.Output]?
        var anonymous: Bool?
    }
    
    public enum Element {
        public enum ArraySize { //bytes for convenience
            case staticSize(UInt64)
            case dynamicSize
            case notArray
        }
        
        case function(Function)
        case constructor(Constructor)
        case fallback(Fallback)
        case event(Event)
        
        public struct InOut {
            public let name: String
            public let type: ParameterType
        }
        
        public struct Function {
            public let name: String?
            public let inputs: [InOut]
            public let outputs: [InOut]
            public let constant: Bool
            public let payable: Bool
        }
        
        public struct Constructor {
            let inputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        public struct Fallback {
            let constant: Bool
            let payable: Bool
        }
        
        public struct Event {
            let name: String
            let inputs: [Input]
            let anonymous: Bool
            
            struct Input {
                let name: String
                let type: ParameterType
                let indexed: Bool
            }
        }
    }
}

extension ABI.Element {
    public func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case .constructor(let constructor):
            guard parameters.count == constructor.inputs.count else {return nil}
            guard let data = ABIEncoder.encode(types: constructor.inputs, values: parameters) else {return nil}
            return data
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            guard parameters.count == function.inputs.count else {return nil}
            let signature = function.methodEncoding
            guard let data = ABIEncoder.encode(types: function.inputs, values: parameters) else {return nil}
            return signature + data
        }
    }
}

extension ABI.Element {
    public func decodeReturnData(_ data: Data) -> [String:Any]? {
        switch self {
        case .constructor(_):
            return nil
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            if (data.count == 0 && function.outputs.count == 1) {
                let name = "0"
                let value = function.outputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.outputs[0].name != "" {
                    returnArray[function.outputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.outputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIDecoder.decode(types: function.outputs, data: data) else {return nil}
            for output in function.outputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if output.name != "" {
                    returnArray[output.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }
    
    public func decodeInputData(_ rawData: Data) -> [String: Any]? {
        var data = rawData
        var sig: Data? = nil
        switch rawData.count % 32 {
        case 0:
            break
        case 4:
            sig = rawData[0 ..< 4]
            data = Data(rawData[4 ..< rawData.count])
        default:
            return nil
        }
        switch self {
        case .constructor(let function):
            if (data.count == 0 && function.inputs.count == 1) {
                let name = "0"
                let value = function.inputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.inputs[0].name != "" {
                    returnArray[function.inputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.inputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIDecoder.decode(types: function.inputs, data: data) else {return nil}
            for input in function.inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            if sig != nil && sig != function.methodEncoding {
                return nil
            }
            if (data.count == 0 && function.inputs.count == 1) {
                let name = "0"
                let value = function.inputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.inputs[0].name != "" {
                    returnArray[function.inputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.inputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIDecoder.decode(types: function.inputs, data: data) else {return nil}
            for input in function.inputs {
                let name = "\(i)"
                returnArray[name] = values[i]
                if input.name != "" {
                    returnArray[input.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }
}

extension ABI.Element.Event {
    public func decodeReturnedLogs(eventLogTopics: [Data], eventLogData: Data) -> [String:Any]? {
        guard let eventContent = ABIDecoder.decodeLog(event: self, eventLogTopics: eventLogTopics, eventLogData: eventLogData) else {return nil}
        return eventContent
    }
}


