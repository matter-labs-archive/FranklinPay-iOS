<h3 align="center">
  <a href="https://thematter.io/">
    <img src="https://scontent-arn2-1.xx.fbcdn.net/v/t1.0-9/42614873_308414336637874_8225471638720741376_n.png?_nc_cat=106&_nc_ht=scontent-arn2-1.xx&oh=36eec27649e6cb3079108415d8bb77b7&oe=5CB0FBF8" width="100" />
    <br />
    The Matter Plasma Implementation
  </a>
</h3>
<p align="center">
  <a href="https://github.com/matterinc/PlasmaContract">Contract</a> &bull;
  <a href="https://github.com/matterinc/plasma.js">TX & Block RLP</a> &bull;
  <a href="https://github.com/matterinc/Plasma_API">API</a> &bull;
  <a href="https://github.com/matterinc/PlasmaManager">JS Lib</a> &bull;
  <a href="https://github.com/matterinc/PlasmaSwiftLib">Swift Lib</a> &bull;
  <a href="https://github.com/matterinc/PlasmaWebExplorer">Block Explorer</a> &bull;
  <a href="https://github.com/matterinc/PlasmaWebUI">Web App</a> &bull;
  <b>iOS App</b></a>
</p>

# Franklin Pay - Secure Dollar Wallet

<img src="https://github.com/matterinc/FranklinPay-iOS/blob/develop/Franklin/App/Assets.xcassets/franklin.imageset/franklin%401x.png" align="center" width="300">

## Freedom is **essential**. Privacy **Matter**!

### What is it?

- Easy and secure way to send money through Matter Plasma
- Universal way to send tokens throught Ethereum blockchain
- Easy way to sign transaction from **any apps**: 
  - mobile
  - web
  - dApps
- **Single and secure** place to store your private key

### So, let's go deeper into those statements:

### Features
- Complete support the Matter Plasma to send money secure, easy and fast
- Let you be **free from hard-bonded solution** like (`Laptop + Chrome + MetaMask + Private key`) binding. 
- **No private key sharing** needed! Store it at one place, sign anywhere!
- Full support of [EIP-681](https://eips.ethereum.org/EIPS/eip-681) (URI scheme)
 Even more:
- Sign transactions and **call arbitrary contract's methods** via deep links

### Franklin Pay testing
To join the Franklin Pay beta, tap the [link](https://testflight.apple.com/join/FVWgauFQ) on your iPhone or iPad after you install TestFlight.

## Purpose

The solution that we **BUIDL**: 
- Mainly this is the best way to use the Matter plasma to make payments
- Also it is the single keystore that accessible from any other applications via deep links and QR codes. It is the most advanced regarding security, and also quite user-friendly

## Contribution:
We are using Swiftlit along with Travis in our project, so you should better have swiftlint installed locally on your machine before contributing. Don't be afraid, it's really simple to install. Just run  `brew install swiftlint`. If you don't have homebrew installed - run `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"` firstly.

In order to manually run autocorrection, print `swiftlint autocorrect` in the project folder via terminal. However, every time you build the project this command will be called automatically.

## Usage of the deeplinks
### Examples of EIP681 links:
- If you want to specify gasPrice, gasLimit just add it to the end of the link:
```
"ethereum:0xaaf3A96b8f5E663Fc47bCc19f14e10A3FD9c414B@4/pay?uint256=100000&value=1000&gasPrice=700000&gasLimit=27500"
```
Here `pay` is just a method on smart contract with the given address and `@4` specifies network id(which is Rinkeby in that case).
`uint256=1000000` is a parameter for the given method, `uint256` is a type of the parameter and `1000000` is a value of that parameter.
`value=1000` is amount in Wei to send to smart contract. 1 ETH = 10^18 Wei.

#### in swift app:
```
//following by EIP-681:
let urlString = "ethereum:0xaaf3A96b8f5E663Fc47bCc19f14e10A3FD9c414B/pay?uint256=100000&value=1000"
UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
```
We have done it in PR: [Peepeth client PR](https://github.com/matterinc/PeepethClient/pull/8)

#### Web app:
[Pull request](https://github.com/ethereum/web3.js/pull/1929), that contains helper functions to work with ethereum links according to eip-681

### Smart contract interaction:
[Smart contract itself](https://rinkeby.etherscan.io/address/0xaaf3a96b8f5e663fc47bcc19f14e10a3fd9c414b):
```
pragma solidity ^0.4.23;

contract Shop {
    mapping(uint256 => bool) invoices;
    
    event InvoicePayed(uint256 invoice);

    function pay(uint256 _invoice) public payable {
        require (!invoices[_invoice] && msg.value > 0);
        invoices[_invoice] = true;
        emit InvoicePayed(_invoice);
    }
}
```
String to encode into QR: `"ethereum:0xaaf3A96b8f5E663Fc47bCc19f14e10A3FD9c414B/pay?uint256=100000&value=1000"`

## Plans (TBD)
During the hackathon, we have covered the whole iOS infrastructure (cross-app transaction signing and sign via QR-code for the calls outside of the phone).
Meanwhile, we want to continue working on that idea and adapt it to the whole Ethereum ecosystem, 
i.e., BUIDL set of the libraries to full reference of FinTech ecosystem::
- Android (TBD)
- JS(PR is during development already)
- IoT libraries + NFC support 

## Final Notes:

All in all, with all those things that will be implemented we will make payments easy, secure and fast
