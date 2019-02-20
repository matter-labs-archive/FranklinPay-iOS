//
//  ABIs.swift
//  DiveLane
//
//  Created by Anton Grigorev on 28/11/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import Foundation

public struct Addresses {
    static let uniswapDai = "0x09cabec1ead1c0ba254b09efb3ee13841712be14"
    static let dai = "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359"
    static let daiToXDai = "0x4aa42145aa6ebf72e164c9bbc74fbd3788045016"
    static let xDaiToDai = "0x7301cfa0e1756b71869e93d4e4dca5c7d0eb0aa6"
    static let buffVending = "0xDb75933075337675af66b97F4468F3B9F6836CaB"
}

public struct ABIs {
    
    static let buffVending = """
[{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"addWhitelisted","inputs":[{"type":"address","name":"account"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"addVendor","inputs":[{"type":"address","name":"_vendorAddress"},{"type":"bytes32","name":"_name"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"removeAdmin","inputs":[{"type":"address","name":"account"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"bool","name":""}],"name":"isAdmin","inputs":[{"type":"address","name":"account"}],"constant":true},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"bytes32","name":"name"},{"type":"bool","name":"isActive"},{"type":"bool","name":"isAllowed"},{"type":"bool","name":"exists"}],"name":"vendors","inputs":[{"type":"address","name":""}],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"removeWhitelisted","inputs":[{"type":"address","name":"account"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"address","name":""}],"name":"superAdmin","inputs":[],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"withdraw","inputs":[{"type":"uint256","name":"amount"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"bool","name":""}],"name":"isWhitelisted","inputs":[{"type":"address","name":"account"}],"constant":true},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"uint256","name":""}],"name":"allowance","inputs":[{"type":"address","name":""}],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"updateVendor","inputs":[{"type":"address","name":"_vendorAddress"},{"type":"bytes32","name":"_name"},{"type":"bool","name":"_isActive"},{"type":"bool","name":"_isAllowed"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"address","name":""}],"name":"tokenContract","inputs":[],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"addAdmin","inputs":[{"type":"address","name":"account"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"renounceAdmin","inputs":[],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"addProduct","inputs":[{"type":"uint256","name":"id"},{"type":"bytes32","name":"name"},{"type":"uint256","name":"cost"},{"type":"bool","name":"isAvailable"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"activateVendor","inputs":[{"type":"bool","name":"_isActive"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"sweep","inputs":[{"type":"uint256","name":"amount"}],"constant":false},{"type":"function","stateMutability":"payable","payable":true,"outputs":[],"name":"deposit","inputs":[],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"renounceWhitelisted","inputs":[],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"bool","name":""}],"name":"isSuperAdmin","inputs":[{"type":"address","name":"account"}],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"adminMint","inputs":[{"type":"address","name":"to"},{"type":"uint256","name":"amount"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"addAllowance","inputs":[{"type":"address","name":"account"},{"type":"uint256","name":"amount"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"uint256","name":"id"},{"type":"uint256","name":"cost"},{"type":"bytes32","name":"name"},{"type":"bool","name":"exists"},{"type":"bool","name":"isAvailable"}],"name":"products","inputs":[{"type":"address","name":""},{"type":"uint256","name":""}],"constant":true},{"type":"constructor","stateMutability":"nonpayable","payable":false,"inputs":[{"type":"address","name":"_tokenContract"}]},{"type":"fallback","stateMutability":"payable","payable":true},{"type":"event","name":"Deposit","inputs":[{"type":"address","name":"depositor","indexed":true},{"type":"uint256","name":"amount","indexed":false}],"anonymous":false},{"type":"event","name":"Withdraw","inputs":[{"type":"address","name":"withdrawer","indexed":true},{"type":"uint256","name":"amount","indexed":false}],"anonymous":false},{"type":"event","name":"UpdateVendor","inputs":[{"type":"address","name":"vendor","indexed":true},{"type":"bytes32","name":"name","indexed":false},{"type":"bool","name":"isActive","indexed":false},{"type":"bool","name":"isAllowed","indexed":false},{"type":"address","name":"sender","indexed":false}],"anonymous":false},{"type":"event","name":"AddProduct","inputs":[{"type":"address","name":"vendor","indexed":true},{"type":"uint256","name":"id","indexed":false},{"type":"uint256","name":"cost","indexed":false},{"type":"bytes32","name":"name","indexed":false},{"type":"bool","name":"isAvailable","indexed":false}],"anonymous":false},{"type":"event","name":"WhitelistedAdded","inputs":[{"type":"address","name":"account","indexed":true}],"anonymous":false},{"type":"event","name":"WhitelistedRemoved","inputs":[{"type":"address","name":"account","indexed":true}],"anonymous":false},{"type":"event","name":"AdminAdded","inputs":[{"type":"address","name":"account","indexed":true}],"anonymous":false},{"type":"event","name":"AdminRemoved","inputs":[{"type":"address","name":"account","indexed":true}],"anonymous":false}]
"""
    
    static let xdaiERC20 = """
[{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"string","name":""}],"name":"name","inputs":[],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[{"type":"bool","name":""}],"name":"approve","inputs":[{"type":"address","name":"spender"},{"type":"uint256","name":"value"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"uint256","name":""}],"name":"totalSupply","inputs":[],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[{"type":"bool","name":""}],"name":"transferFrom","inputs":[{"type":"address","name":"from"},{"type":"address","name":"to"},{"type":"uint256","name":"value"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[{"type":"bool","name":""}],"name":"transferWithData","inputs":[{"type":"address","name":"to"},{"type":"uint256","name":"value"},{"type":"bytes","name":"data"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"uint8","name":""}],"name":"decimals","inputs":[],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[{"type":"bool","name":""}],"name":"increaseAllowance","inputs":[{"type":"address","name":"spender"},{"type":"uint256","name":"addedValue"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[{"type":"bool","name":""}],"name":"mint","inputs":[{"type":"address","name":"to"},{"type":"uint256","name":"amount"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"address","name":""}],"name":"vendingMachine","inputs":[],"constant":true},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"uint256","name":""}],"name":"balanceOf","inputs":[{"type":"address","name":"owner"}],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"renounceOwnership","inputs":[],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"changeVendingMachine","inputs":[{"type":"address","name":"newVendingMachine"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"address","name":""}],"name":"owner","inputs":[],"constant":true},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"bool","name":""}],"name":"isOwner","inputs":[],"constant":true},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"string","name":""}],"name":"symbol","inputs":[],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[{"type":"bool","name":""}],"name":"burn","inputs":[{"type":"address","name":"from"},{"type":"uint256","name":"value"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[{"type":"bool","name":""}],"name":"decreaseAllowance","inputs":[{"type":"address","name":"spender"},{"type":"uint256","name":"subtractedValue"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[{"type":"bool","name":""}],"name":"transfer","inputs":[{"type":"address","name":"to"},{"type":"uint256","name":"value"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"uint256","name":""}],"name":"allowance","inputs":[{"type":"address","name":"owner"},{"type":"address","name":"spender"}],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"transferOwnership","inputs":[{"type":"address","name":"newOwner"}],"constant":false},{"type":"constructor","stateMutability":"nonpayable","payable":false,"inputs":[{"type":"string","name":"_name"},{"type":"string","name":"_symbol"}]},{"type":"event","name":"TransferWithData","inputs":[{"type":"address","name":"from","indexed":true},{"type":"address","name":"to","indexed":true},{"type":"uint256","name":"value","indexed":false},{"type":"bytes","name":"data","indexed":false}],"anonymous":false},{"type":"event","name":"OwnershipTransferred","inputs":[{"type":"address","name":"previousOwner","indexed":true},{"type":"address","name":"newOwner","indexed":true}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"type":"address","name":"from","indexed":true},{"type":"address","name":"to","indexed":true},{"type":"uint256","name":"value","indexed":false}],"anonymous":false},{"type":"event","name":"Approval","inputs":[{"type":"address","name":"owner","indexed":true},{"type":"address","name":"spender","indexed":true},{"type":"uint256","name":"value","indexed":false}],"anonymous":false}]
"""
    
    static let xdai = """
[{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"address","name":""}],"name":"proxyOwner","inputs":[],"constant":true},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"upgradeTo","inputs":[{"type":"uint256","name":"version"},{"type":"address","name":"implementation"}],"constant":false},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"uint256","name":""}],"name":"version","inputs":[],"constant":true},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"address","name":""}],"name":"implementation","inputs":[],"constant":true},{"type":"function","stateMutability":"view","payable":false,"outputs":[{"type":"address","name":""}],"name":"upgradeabilityOwner","inputs":[],"constant":true},{"type":"function","stateMutability":"payable","payable":true,"outputs":[],"name":"upgradeToAndCall","inputs":[{"type":"uint256","name":"version"},{"type":"address","name":"implementation"},{"type":"bytes","name":"data"}],"constant":false},{"type":"function","stateMutability":"nonpayable","payable":false,"outputs":[],"name":"transferProxyOwnership","inputs":[{"type":"address","name":"newOwner"}],"constant":false},{"type":"fallback","stateMutability":"payable","payable":true},{"type":"event","name":"ProxyOwnershipTransferred","inputs":[{"type":"address","name":"previousOwner","indexed":false},{"type":"address","name":"newOwner","indexed":false}],"anonymous":false},{"type":"event","name":"Upgraded","inputs":[{"type":"uint256","name":"version","indexed":false},{"type":"address","name":"implementation","indexed":true}],"anonymous":false}]
"""
    
    static let dai = """
[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"stop","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"guy","type":"address"},{"name":"wad","type":"uint256"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"owner_","type":"address"}],"name":"setOwner","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"src","type":"address"},{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"guy","type":"address"},{"name":"wad","type":"uint256"}],"name":"mint","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"wad","type":"uint256"}],"name":"burn","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"name_","type":"bytes32"}],"name":"setName","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"src","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"stopped","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"authority_","type":"address"}],"name":"setAuthority","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"guy","type":"address"},{"name":"wad","type":"uint256"}],"name":"burn","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"wad","type":"uint256"}],"name":"mint","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"transfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"push","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"src","type":"address"},{"name":"dst","type":"address"},{"name":"wad","type":"uint256"}],"name":"move","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"start","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"authority","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"guy","type":"address"}],"name":"approve","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"src","type":"address"},{"name":"guy","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"src","type":"address"},{"name":"wad","type":"uint256"}],"name":"pull","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"symbol_","type":"bytes32"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"guy","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Mint","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"guy","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Burn","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"authority","type":"address"}],"name":"LogSetAuthority","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"}],"name":"LogSetOwner","type":"event"},{"anonymous":true,"inputs":[{"indexed":true,"name":"sig","type":"bytes4"},{"indexed":true,"name":"guy","type":"address"},{"indexed":true,"name":"foo","type":"bytes32"},{"indexed":true,"name":"bar","type":"bytes32"},{"indexed":false,"name":"wad","type":"uint256"},{"indexed":false,"name":"fax","type":"bytes"}],"name":"LogNote","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"guy","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"src","type":"address"},{"indexed":true,"name":"dst","type":"address"},{"indexed":false,"name":"wad","type":"uint256"}],"name":"Transfer","type":"event"}]
"""
    
    static let uniswap = """
[
{
"name": "TokenPurchase",
"inputs": [
{
"type": "address",
"name": "buyer",
"indexed": true
},
{
"type": "uint256",
"name": "eth_sold",
"indexed": true
},
{
"type": "uint256",
"name": "tokens_bought",
"indexed": true
}
],
"anonymous": false,
"type": "event"
},
{
"name": "EthPurchase",
"inputs": [
{
"type": "address",
"name": "buyer",
"indexed": true
},
{
"type": "uint256",
"name": "tokens_sold",
"indexed": true
},
{
"type": "uint256",
"name": "eth_bought",
"indexed": true
}
],
"anonymous": false,
"type": "event"
},
{
"name": "AddLiquidity",
"inputs": [
{
"type": "address",
"name": "provider",
"indexed": true
},
{
"type": "uint256",
"name": "eth_amount",
"indexed": true
},
{
"type": "uint256",
"name": "token_amount",
"indexed": true
}
],
"anonymous": false,
"type": "event"
},
{
"name": "RemoveLiquidity",
"inputs": [
{
"type": "address",
"name": "provider",
"indexed": true
},
{
"type": "uint256",
"name": "eth_amount",
"indexed": true
},
{
"type": "uint256",
"name": "token_amount",
"indexed": true
}
],
"anonymous": false,
"type": "event"
},
{
"name": "Transfer",
"inputs": [
{
"type": "address",
"name": "_from",
"indexed": true
},
{
"type": "address",
"name": "_to",
"indexed": true
},
{
"type": "uint256",
"name": "_value",
"indexed": false
}
],
"anonymous": false,
"type": "event"
},
{
"name": "Approval",
"inputs": [
{
"type": "address",
"name": "_owner",
"indexed": true
},
{
"type": "address",
"name": "_spender",
"indexed": true
},
{
"type": "uint256",
"name": "_value",
"indexed": false
}
],
"anonymous": false,
"type": "event"
},
{
"name": "setup",
"outputs": [],
"inputs": [
{
"type": "address",
"name": "token_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 175875
},
{
"name": "addLiquidity",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "min_liquidity"
},
{
"type": "uint256",
"name": "max_tokens"
},
{
"type": "uint256",
"name": "deadline"
}
],
"constant": false,
"payable": true,
"type": "function",
"gas": 82616
},
{
"name": "removeLiquidity",
"outputs": [
{
"type": "uint256",
"name": "out"
},
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "amount"
},
{
"type": "uint256",
"name": "min_eth"
},
{
"type": "uint256",
"name": "min_tokens"
},
{
"type": "uint256",
"name": "deadline"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 116814
},
{
"name": "__default__",
"outputs": [],
"inputs": [],
"constant": false,
"payable": true,
"type": "function"
},
{
"name": "ethToTokenSwapInput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "min_tokens"
},
{
"type": "uint256",
"name": "deadline"
}
],
"constant": false,
"payable": true,
"type": "function",
"gas": 12757
},
{
"name": "ethToTokenTransferInput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "min_tokens"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "recipient"
}
],
"constant": false,
"payable": true,
"type": "function",
"gas": 12965
},
{
"name": "ethToTokenSwapOutput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_bought"
},
{
"type": "uint256",
"name": "deadline"
}
],
"constant": false,
"payable": true,
"type": "function",
"gas": 50463
},
{
"name": "ethToTokenTransferOutput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_bought"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "recipient"
}
],
"constant": false,
"payable": true,
"type": "function",
"gas": 50671
},
{
"name": "tokenToEthSwapInput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_sold"
},
{
"type": "uint256",
"name": "min_eth"
},
{
"type": "uint256",
"name": "deadline"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 47503
},
{
"name": "tokenToEthTransferInput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_sold"
},
{
"type": "uint256",
"name": "min_eth"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "recipient"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 47712
},
{
"name": "tokenToEthSwapOutput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "eth_bought"
},
{
"type": "uint256",
"name": "max_tokens"
},
{
"type": "uint256",
"name": "deadline"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 50175
},
{
"name": "tokenToEthTransferOutput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "eth_bought"
},
{
"type": "uint256",
"name": "max_tokens"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "recipient"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 50384
},
{
"name": "tokenToTokenSwapInput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_sold"
},
{
"type": "uint256",
"name": "min_tokens_bought"
},
{
"type": "uint256",
"name": "min_eth_bought"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "token_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 51007
},
{
"name": "tokenToTokenTransferInput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_sold"
},
{
"type": "uint256",
"name": "min_tokens_bought"
},
{
"type": "uint256",
"name": "min_eth_bought"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "recipient"
},
{
"type": "address",
"name": "token_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 51098
},
{
"name": "tokenToTokenSwapOutput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_bought"
},
{
"type": "uint256",
"name": "max_tokens_sold"
},
{
"type": "uint256",
"name": "max_eth_sold"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "token_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 54928
},
{
"name": "tokenToTokenTransferOutput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_bought"
},
{
"type": "uint256",
"name": "max_tokens_sold"
},
{
"type": "uint256",
"name": "max_eth_sold"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "recipient"
},
{
"type": "address",
"name": "token_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 55019
},
{
"name": "tokenToExchangeSwapInput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_sold"
},
{
"type": "uint256",
"name": "min_tokens_bought"
},
{
"type": "uint256",
"name": "min_eth_bought"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "exchange_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 49342
},
{
"name": "tokenToExchangeTransferInput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_sold"
},
{
"type": "uint256",
"name": "min_tokens_bought"
},
{
"type": "uint256",
"name": "min_eth_bought"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "recipient"
},
{
"type": "address",
"name": "exchange_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 49532
},
{
"name": "tokenToExchangeSwapOutput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_bought"
},
{
"type": "uint256",
"name": "max_tokens_sold"
},
{
"type": "uint256",
"name": "max_eth_sold"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "exchange_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 53233
},
{
"name": "tokenToExchangeTransferOutput",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_bought"
},
{
"type": "uint256",
"name": "max_tokens_sold"
},
{
"type": "uint256",
"name": "max_eth_sold"
},
{
"type": "uint256",
"name": "deadline"
},
{
"type": "address",
"name": "recipient"
},
{
"type": "address",
"name": "exchange_addr"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 53423
},
{
"name": "getEthToTokenInputPrice",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "eth_sold"
}
],
"constant": true,
"payable": false,
"type": "function",
"gas": 5542
},
{
"name": "getEthToTokenOutputPrice",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_bought"
}
],
"constant": true,
"payable": false,
"type": "function",
"gas": 6872
},
{
"name": "getTokenToEthInputPrice",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "tokens_sold"
}
],
"constant": true,
"payable": false,
"type": "function",
"gas": 5637
},
{
"name": "getTokenToEthOutputPrice",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "uint256",
"name": "eth_bought"
}
],
"constant": true,
"payable": false,
"type": "function",
"gas": 6897
},
{
"name": "tokenAddress",
"outputs": [
{
"type": "address",
"name": "out"
}
],
"inputs": [],
"constant": true,
"payable": false,
"type": "function",
"gas": 1413
},
{
"name": "factoryAddress",
"outputs": [
{
"type": "address",
"name": "out"
}
],
"inputs": [],
"constant": true,
"payable": false,
"type": "function",
"gas": 1443
},
{
"name": "balanceOf",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "address",
"name": "_owner"
}
],
"constant": true,
"payable": false,
"type": "function",
"gas": 1645
},
{
"name": "transfer",
"outputs": [
{
"type": "bool",
"name": "out"
}
],
"inputs": [
{
"type": "address",
"name": "_to"
},
{
"type": "uint256",
"name": "_value"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 75034
},
{
"name": "transferFrom",
"outputs": [
{
"type": "bool",
"name": "out"
}
],
"inputs": [
{
"type": "address",
"name": "_from"
},
{
"type": "address",
"name": "_to"
},
{
"type": "uint256",
"name": "_value"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 110907
},
{
"name": "approve",
"outputs": [
{
"type": "bool",
"name": "out"
}
],
"inputs": [
{
"type": "address",
"name": "_spender"
},
{
"type": "uint256",
"name": "_value"
}
],
"constant": false,
"payable": false,
"type": "function",
"gas": 38769
},
{
"name": "allowance",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [
{
"type": "address",
"name": "_owner"
},
{
"type": "address",
"name": "_spender"
}
],
"constant": true,
"payable": false,
"type": "function",
"gas": 1925
},
{
"name": "name",
"outputs": [
{
"type": "bytes32",
"name": "out"
}
],
"inputs": [],
"constant": true,
"payable": false,
"type": "function",
"gas": 1623
},
{
"name": "symbol",
"outputs": [
{
"type": "bytes32",
"name": "out"
}
],
"inputs": [],
"constant": true,
"payable": false,
"type": "function",
"gas": 1653
},
{
"name": "decimals",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [],
"constant": true,
"payable": false,
"type": "function",
"gas": 1683
},
{
"name": "totalSupply",
"outputs": [
{
"type": "uint256",
"name": "out"
}
],
"inputs": [],
"constant": true,
"payable": false,
"type": "function",
"gas": 1713
}
]
"""
    
    static let peepeth = """
[ { "constant": false, "inputs": [ { "name": "_followee", "type": "address" } ], "name": "unFollow", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "updateAccount", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": true, "inputs": [], "name": "isActive", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_isActive", "type": "bool" } ], "name": "setIsActive", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_followee", "type": "address" } ], "name": "follow", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_name", "type": "bytes16" } ], "name": "changeName", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": true,
"inputs": [ { "name": "", "type": "address" } ], "name": "names",
"outputs": [ { "name": "", "type": "bytes32" } ],
"payable": false, "stateMutability": "view", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "reply", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": true,
"inputs": [ { "name": "", "type": "bytes32" } ], "name": "addresses",
"outputs": [ { "name": "", "type": "address" } ],
"payable": false, "stateMutability": "view", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_address", "type": "address" } ], "name": "setNewAddress", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": true,
"inputs": [ { "name": "_addr", "type": "address" } ], "name": "accountExists",
"outputs": [ { "name": "", "type": "bool" } ],
"payable": false, "stateMutability": "view", "type": "function" },
{ "constant": true,
"inputs": [ { "name": "bStr", "type": "bytes16" } ], "name": "isValidName",
"outputs": [ { "name": "", "type": "bool" } ],
"payable": false, "stateMutability": "pure", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "share", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "saveBatch", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false, "inputs": [], "name": "cashout", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": true, "inputs": [], "name": "owner", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_ipfsHash", "type": "string" } ], "name": "post", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false,
"inputs": [ { "name": "_name", "type": "bytes16" }, { "name": "_ipfsHash", "type": "string" } ], "name": "createAccount",
"outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false,
"inputs": [ { "name": "newMinPercentage", "type": "uint256" } ], "name": "setMinSiteTipPercentage",
"outputs": [],
"payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false,
"inputs": [ { "name": "_author", "type": "address" }, { "name": "_messageID", "type": "string" },
{ "name": "_ownerTip", "type": "uint256" }, { "name": "_ipfsHash", "type": "string" } ],
"name": "tip",
"outputs": [],
"payable": true, "stateMutability": "payable", "type": "function" },
{ "constant": true, "inputs": [], "name": "newAddress", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" },
{ "constant": true,
"inputs": [ { "name": "", "type": "uint256" } ], "name": "interfaceInstances",
"outputs": [ { "name": "interfaceAddress", "type": "address" }, { "name": "startBlock", "type": "uint96" } ],
"payable": false, "stateMutability": "view", "type": "function" },
{ "constant": false, "inputs": [ { "name": "_address", "type": "address" } ], "name": "transferAccount", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": false, "inputs": [], "name": "lockMinSiteTipPercentage", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": true, "inputs": [], "name": "interfaceInstanceCount", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" },
{ "constant": true, "inputs": [], "name": "minSiteTipPercentage", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" },
{ "constant": false, "inputs": [ { "name": "newOwner", "type": "address" } ], "name": "transferOwnership", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" },
{ "constant": true, "inputs": [], "name": "tipPercentageLocked", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" },
{ "inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor" },
{ "payable": true, "stateMutability": "payable", "type": "fallback" },
{ "anonymous": false, "inputs": [], "name": "PeepethEvent", "type": "event" } ]
"""

}
