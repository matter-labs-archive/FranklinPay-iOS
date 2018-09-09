# DiveLane - Apple Pay for Ethereum

<img src="https://github.com/matterinc/DiveLane/blob/master/dive%20logo.png" align="center" width="300">

Check out our [presentation](https://github.com/matterinc/DiveLane/blob/master/DiveLanePresentation.pdf) and [screencast](https://www.youtube.com/watch?v=Uidm5YccUas)
It will give you a brief overview of Dive Lane and it's message.

## Freedom is **essential**. Privacy **Matter**!

### What is it?

- The universal way to sign transaction from **any apps**: 
  - mobile
  - web
  - dApps
- **Single and secure** place to store your private key.
-  Transactions signer

### So, let's go deeper into those statements:

### Features
- Let you be **free from hard-bonded solution** like (`Laptop + Chrome + MetaMask + Private key`) binding. 
- **No private key sharing** needed! Store it at one place, sign anywhere!
- Full support of [EIP-681](https://eips.ethereum.org/EIPS/eip-681) (URI scheme)
 Even more:
- Sign transactions and **call arbitrary contract's methods** via deep links

## Purpose

The solution that we **BUIDL**: a single keystore that accessible from any other applications via deep links and QR codes. It is the most advanced regarding security, and also quite user-friendly.


### Kinda bridge between scientists and crypto-geeks and regular programmers:
Lots of experienced developers decline creation of DApps because of its technical hardness and, as a result, those apps are mostly written by scientific people, which don't know how to create excellent UX experience for their users. We want to provide a convenient way to avoid interaction with storing keys, signing and sending transactions, so great mobile developers could come into play and BUIDL amazing apps, without worrying about all that math around blockchain. 
We did all the hard-lifting cryptography job done for you!

## Usage:

### in swift app:
```
//following by EIP-681:
let urlString = "ethereum:0xaaf3A96b8f5E663Fc47bCc19f14e10A3FD9c414B/pay?uint256=100000&value=1000"
UIApplication.shared.open(URL(string: urlString)!, options: [:], completionHandler: nil)
```
We have done it in PR: [Peepeth client PR](https://github.com/matterinc/PeepethClient/pull/8)


### Web app:

[Pull request](https://github.com/ethereum/web3.js/pull/1929), that contains helper functions to work with ethereum links according to eip-681



## Smart contract interaction:
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
- Android (TBD), 
- JS(PR is during development already), 
- IoT libraries + NFC support 

## Final Notes:

All in all, with all those things that will be implemented we will make ETH interaction as easy as wireless pay.
