//
//  IgnisTransaction.swift
//  Franklin
//
//  Created by Anton on 12/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress
import BigInt

import JavaScriptCore

public class TransactionIgnis {
    lazy var context: JSContext? = {
        let context = JSContext()
        guard let
            jsPath = Bundle.main.path(forResource: "bundle", ofType: "js") else {
                print("Unable to read resource files.")
                return nil
        }
        do {
            let bundle = try String(contentsOfFile: jsPath, encoding: String.Encoding.utf8)
            context?.evaluateScript(bundle)
        } catch (let error) {
            print("Error while processing script file: \(error)")
        }
        
        return context
    }()
    
    func main() {
        guard let context = context else {
            print("JSContext not found.")
            return
        }
        
        let mainFunction = context.objectForKeyedSubscript("main")
//        let add = addFunction?.invokeMethod("add", withArguments: [])
//        return add
        guard let main = mainFunction?.call(withArguments: []) else {
            print("Unable to parse JSON")
            return
        }
        print("Ready!")
    }
}
