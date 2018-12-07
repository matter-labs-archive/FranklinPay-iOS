//
//  ENS.swift
//  DiveLane
//
//  Created by Anton Grigorev on 07/12/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation
import BigInt
import EthereumAddress
import Web3swift

public struct ResolverENS {
    let web3: web3
    let resolverAddress: EthereumAddress
    
    public enum InterfaceName {
        case addr
        case name
        case ABI
        case pubkey
        case content
        case multihash
        case text
        
        func hash() -> String {
            switch self {
            case .ABI:
                return "0x2203ab56"
            case .addr:
                return "0x3b3b57de"
            case .name:
                return "0x691f3431"
            case .pubkey:
                return "0xc8690233"
            case .content:
                return "0xd8389dc5"
            case .multihash:
                return "0xe89401a1"
            case .text:
                return "0x59d1d43c"
            }
        }
    }
    
    lazy var resolverContract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.resolverABI, at: self.resolverAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    lazy var defaultOptions: TransactionOptions = {
        return TransactionOptions.defaultOptions
    }()
    
    init(web3: web3, resolverAddress: EthereumAddress) {
        self.web3 = web3
        self.resolverAddress = resolverAddress
    }
    
    mutating public func supportsInterface(interfaceID: Data) throws -> Bool {
        guard let supports = try? supportsInterface(interfaceID: interfaceID.toHexString()) else {throw Web3Error.processingError(desc: "Can't get answer")}
        return supports
    }
    
    // MARK: - returns true if the contract supports given interface
    mutating public func supportsInterface(interfaceID: String) throws -> Bool {
        guard let transaction = self.resolverContract.read("supportsInterface", parameters: [interfaceID as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let supports = result["0"] as? Bool else {throw Web3Error.processingError(desc: "Can't get answer")}
        return supports
    }
    
    // MARK: - returns address for the given domain at given resolver
    mutating public func addr(forDomain domain: String) throws -> EthereumAddress {
        guard let nameHash = NameHash.nameHash(domain) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("addr", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "Can't get address")}
        return address
    }
    
    //function setAddr(bytes32 node, address addr)
    mutating public func setAddr(node: String, address: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setAddr", parameters: [nameHash, address] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    // MARK: - returns corresponding ENS to the requested node
    mutating public func name(node: String) throws -> String {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("name", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let name = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get name")}
        return name
    }
    
    mutating func setName(node: String, name: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setName", parameters: [nameHash, name] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    // MARK: - returns ABI in the requested encodings
    mutating public func ABI(node: String, contentType: BigUInt) throws -> (BigUInt, Data) {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("ABI", parameters: [nameHash, contentType] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let encoding = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "Can't get encoding")}
        guard let data = result["1"] as? Data else {throw Web3Error.processingError(desc: "Can't get data")}
        return (encoding, data)
    }
    
    mutating func setABI(node: String, contentType: BigUInt, data: Data, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setABI", parameters: [nameHash, contentType, data] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    // MARK: - returns x and y coordinates
    mutating public func pubkey(node: String) throws -> PublicKey {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("pubkey", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let x = result["x"] as? Data else {throw Web3Error.processingError(desc: "Can't get x")}
        guard let y = result["y"] as? Data else {throw Web3Error.processingError(desc: "Can't get y")}
        let pubkey = PublicKey(x: "0x" + x.toHexString(), y: "0x" + y.toHexString())
        return pubkey
    }
    
    mutating public func setPubkey(node: String, x: String, y: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setPubkey", parameters: [nameHash, x, y] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    mutating func content(node: String) throws -> String {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("content", parameters: [nameHash] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let content = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get content")}
        return content
    }
    
    mutating func setContent(node: String, hash: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setContent", parameters: [nameHash, hash] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    //function multihash(bytes32 node) public view returns (bytes)
    mutating public func multihash(node: String) throws -> Data {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("multihash", parameters: [nameHash] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let multihash = result["0"] as? Data else {throw Web3Error.processingError(desc: "Can't get multihash")}
        return multihash
    }
    //function setMultihash(bytes32 node, bytes hash) public only_owner(node)
    mutating public func setMultihash(node: String, hash: Data, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setMultihash", parameters: [nameHash, hash] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    //function text(bytes32 node, string key) public view returns (string)
    mutating public func text(node: String, key: String) throws -> String {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.read("text", parameters: [nameHash, key] as [AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let text = result["0"] as? String else {throw Web3Error.processingError(desc: "Can't get text")}
        return text
    }
    //function setText(bytes32 node, string key, string value) public only_owner(node)
    mutating public func setText(node: String, key: String, value: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.resolverContract.write("setText", parameters: [nameHash, key, value] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    private func getOptions(_ options: TransactionOptions) -> TransactionOptions {
        var options = options
        options.to = self.resolverAddress
        return options
    }
}

public struct PublicKey {
    let x: String
    let y: String
}

public class ENS {
    
    let web3: web3
    let ensContractAddress: EthereumAddress?
    
    init(web3: web3) {
        self.web3 = web3
        switch web3.provider.network {
        case .Mainnet?:
            ensContractAddress = EthereumAddress("0x314159265dd8dbb310642f98f50c066173c1259b")
        case .Rinkeby?:
            ensContractAddress = EthereumAddress("0xe7410170f87102df0055eb195163a03b7f2bff4a")
        case .Ropsten?:
            ensContractAddress = EthereumAddress("0x112234455c3a32fd11230c42e7bccd4a84e02010")
        default:
            ensContractAddress = nil
        }
    }
    
    lazy var registryContract: web3.web3contract = {
        let contract = self.web3.contract(Web3.Utils.ensRegistryABI, at: self.ensContractAddress, abiVersion: 2)
        precondition(contract != nil)
        return contract!
    }()
    
    lazy var defaultOptions: TransactionOptions = {
        return TransactionOptions.defaultOptions
    }()
    
    // MARK: - Convenience methods
    public func getAddress(_ domain: String) throws -> EthereumAddress {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let isAddrSupports = try? resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash()) else {throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")}
        guard isAddrSupports else {throw Web3Error.processingError(desc: "Address isn't supported")}
        guard let addr = try? resolver.addr(forDomain: domain) else {throw Web3Error.processingError(desc: "Can't get address")}
        return addr
    }
    
    public func setAddress(domain: String, address: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let isAddrSupports = try? resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.addr.hash()) else {throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")}
        guard isAddrSupports else {throw Web3Error.processingError(desc: "Address isn't supported")}
        guard let result = try? resolver.setAddr(node: domain, address: address, options: options, password: password) else {throw Web3Error.processingError(desc: "Can't get result")}
        return result
    }
    
    public func getPubkey(domain: String) throws -> PublicKey {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let isPubkeySupports = try? resolver.supportsInterface(interfaceID: ResolverENS.InterfaceName.pubkey.hash()) else {throw Web3Error.processingError(desc: "Resolver don't support interface with this ID")}
        guard isPubkeySupports else {throw Web3Error.processingError(desc: "Pubkey isn't supported")}
        guard let pubkey = try? resolver.pubkey(node: domain) else {throw Web3Error.processingError(desc: "Can't get pubkey")}
        return pubkey
    }
    
    public func setPubkey(domain: String, x: String, y: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let result = try? resolver.setPubkey(node: domain, x: x, y: y, options: options, password: password) else {throw Web3Error.processingError(desc: "Can't get result")}
        return result
    }
    
    public func getContent(domain: String) throws -> String {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let content = try? resolver.content(node: domain) else {throw Web3Error.processingError(desc: "Can't get content")}
        return content
    }
    
    public func setContent(domain: String, hash: String, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let result = try? resolver.setContent(node: domain, hash: hash, options: options, password: password) else {throw Web3Error.processingError(desc: "Can't get result")}
        return result
    }
    
    public func getMultihash(domain: String) throws -> Data {
        guard var resolver = try? self.resolver(forDomain: domain) else {throw Web3Error.processingError(desc: "Failed to get resolver for domain")}
        guard let multihash = try? resolver.multihash(node: domain) else {throw Web3Error.processingError(desc: "Can't get multihash")}
        return multihash
    }
    
    // MARK: - Returns resolver for the given domain
    public func resolver(forDomain domain: String) throws -> ResolverENS {
        guard let nameHash = NameHash.nameHash(domain) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.read("resolver", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let resolverAddress = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "No address in result")}
        return ResolverENS(web3: self.web3, resolverAddress: resolverAddress)
    }
    
    //Returns node's owner address
    public func owner(node: String) throws -> EthereumAddress {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.read("owner", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let address = result["0"] as? EthereumAddress else {throw Web3Error.processingError(desc: "No address in result")}
        return address
    }
    
    //Untested
    public func ttl(node: String) throws -> BigUInt {
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.read("ttl", parameters: [nameHash as AnyObject], extraData: Data(), transactionOptions: defaultOptions) else {throw Web3Error.transactionSerializationError}
        guard let result = try? transaction.call(transactionOptions: defaultOptions) else {throw Web3Error.processingError(desc: "Can't call transaction")}
        guard let ans = result["0"] as? BigUInt else {throw Web3Error.processingError(desc: "No answer in result")}
        return ans
    }
    
    //    function setOwner(bytes32 node, address owner);
    public func setOwner(node: String, owner: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.write("setOwner", parameters: [nameHash, owner] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    public func setSubnodeOwner(node: String, label: String, owner: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let labelHash = NameHash.nameHash(label) else {throw Web3Error.processingError(desc: "Failed to get label hash")}
        guard let transaction = self.registryContract.write("setSubnodeOwner", parameters: [nameHash, labelHash, owner] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //    function setResolver(bytes32 node, address resolver);
    public func setResolver(node: String, resolver: EthereumAddress, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.write("setResolver", parameters: [nameHash, resolver] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    //    function setTTL(bytes32 node, uint64 ttl);
    public func setTTL(node: String, ttl: BigUInt, options: TransactionOptions, password: String? = nil) throws -> TransactionSendingResult {
        let options = getOptions(options)
        guard let nameHash = NameHash.nameHash(node) else {throw Web3Error.processingError(desc: "Failed to get name hash")}
        guard let transaction = self.registryContract.write("setTTL", parameters: [nameHash, ttl] as [AnyObject], extraData: Data(), transactionOptions: options) else {throw Web3Error.transactionSerializationError}
        guard let result = password == nil ? try? transaction.send() : try? transaction.send(password: password!, transactionOptions: options) else {throw Web3Error.processingError(desc: "Can't send transaction")}
        return result
    }
    
    private func getOptions(_ options: TransactionOptions) -> TransactionOptions {
        var options = options
        options.to = self.ensContractAddress
        return options
    }
}
