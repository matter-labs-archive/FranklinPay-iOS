# PlasmaSwiftLib

[![Build Status](https://travis-ci.com/matterinc/PlasmaSwiftLib.svg?branch=master)](https://travis-ci.com/matterinc/PlasmaSwiftLib)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/PlasmaSwiftLib.svg)](https://img.shields.io/cocoapods/v/PlasmaSwiftLib.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/PlasmaSwiftLib.svg?style=flat)](https://plasmaswiftlib.github.io/PlasmaSwiftLib)
[![License](https://img.shields.io/cocoapods/l/PlasmaSwiftLib.svg?style=flat)](http://cocoapods.org/pods/PlasmaSwiftLib)

<img align="left" width="25" height="25" src="https://user-images.githubusercontent.com/28599454/41086111-af4bc3b0-6a41-11e8-9f9f-2d642b12666e.png">[Ask questions](https://stackoverflow.com/questions/tagged/PlasmaSwiftLib)

**PlasmaSwiftLib** is your toolbelt for any kind of interactions with The Matter Plasma Implementations.

<!-- toc -->

- [Features](#features)
- [Design Decisions](#design-decisions)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
  * [CocoaPods](#cocoapods)
  * [Carthage](#carthage)
- [Example Project](#example-project)
- [Credits](#credits)
  * [Security Disclosure](#security-disclosure)
- [Donations](#donations)
- [License](#license)

<!-- tocstop -->

---
  - [Usage Doc](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md)
	- **UTXO** 
		- [UTXO structure](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#utxo-structure)
		- [Get UTXOs list for Ethereum address](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#get-utxos-list-for-ethereum-address)
	- **Transaction** 
		- [Form input](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#form-input)
		- [Form output](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#form-output)
		- [Form transaction and sign it](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#form-transaction-and-sign-it)
	- **Blocks**
		- [Get last written block, print its headers and check if transactions count is equal in Block header and in Block transactions array](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#get-last-written-block-print-its-headers-and-check-if-transactions-count-is-equal-in-block-header-and-in-block-transactions-array)
	- **Send transaction in Plasma** 
		- [Send raw transaction (Split example)](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#send-raw-transaction-split-example)
	- **Send transaction to Plasma Contract** 
		- [Send raw transaction (Put deposit example)](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#send-raw-transaction-put-deposit-example)
		- [Withdraw for chosen utxo](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#withdraw-for-chosen-utxo)
	- **Outputs management** 
		- [Merge outputs for fixed amount of one output](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#merge-outputs-for-fixed-amount-of-one-output)
		- [Merge outputs for fixed number of outputs](https://github.com/matterinc/PlasmaSwiftLib/blob/develop/Documentation/Usage.md#merge-outputs-for-fixed-number-of-outputs)

## Features

- [x] Based on [More Viable Plasma Implementation](https://github.com/matterinc/PlasmaContract) by The Matter Team
- [x] RLP encoding and decoding
- [x] Comprehensive Unit and Integration Test Coverage
- [x] [Complete Documentation](https://matterinc.github.io/PlasmaSwiftLib)

## Design Decisions

- Functionality was focused on serializing and signing transactions locally on the device
- Sending raw transactions to The Matter Plasma network using REST API
- Sending raw transactions to Plasma Contract using [The Matter web3swift](https://github.com/matterinc/web3swift)

## Requirements

- iOS 9.0+ / macOS 10.11+
- Xcode 10.0+
- Swift 4.2+

## Communication

When using this lib, please make references to this repo and give your start! :)
*Nothing makes developers happier than seeing someone else use our work and go wild with it.*

If you are using PlasmaSwiftLib in your app or know of an app that uses it, please add it to [this list](https://github.com/matterinc/PlasmaSwiftLib/wiki/Apps-using-PlasmaSwiftLib).

- If you **need help**, use [Stack Overflow](https://stackoverflow.com/questions/tagged/PlasmaSwiftLib) and tag `PlasmaSwiftLib`.
- If you'd like to **see PlasmaSwiftLib best practices**, check [Apps using this library](https://github.com/matterinc/PlasmaSwiftLib/wiki/Apps-using-PlasmaSwiftLib).
- If you **found a bug**, [open an issue](https://github.com/matterinc/PlasmaSwiftLib/issues).
- If you **have a feature request**, [open an issue](https://github.com/matterinc/PlasmaSwiftLib/issues).
- If you **want to contribute**, [submit a pull request](https://github.com/matterinc/PlasmaSwiftLib/pulls).

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods
```

To integrate PlasmaSwiftLib into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target '<Your Target Name>' do
    use_frameworks!
    pod 'PlasmaSwiftLib', '~> 1.0.7'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PlasmaSwiftLib into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "matterinc/PlasmaSwiftLib" "carthage"
```

Run `carthage update` to build the framework and drag the built `web3swift.framework` into your Xcode project.

## Example Project

You can try lib by running the example project:

- Clone the repo: `git clone https://github.com/matterinc/PlasmaSwiftLib.git`
- Move to the repo: `cd PlasmaSwiftLib/Example/PlasmaSwiftLibExample`
- Install Dependencies: `pod install`
- Open: `open ./PlasmaSwiftLibExample.xcworkspace`

## Credits

Anton Grigorev, [@BaldyAsh](https://github.com/BaldyAsh), antongrigorjev2010@gmail.com

Alex Vlasov, [@shamatar](https://github.com/shamatar),  alex.m.vlasov@gmail.com

### Security Disclosure

If you believe you have identified a security vulnerability with PlasmaSwiftLib, you should report it as soon as possible via email to [Anton Grigorev](https://github.com/BaldyAsh) antongrigorjev2010@gmail.com. Please do not post it to a public issue tracker.

## Donations

[The Matters](https://github.com/orgs/matterinc/people) are charged with open-sorсe and do not require money for using their `PlasmaSwiftLib`.
We want to continue to do everything we can to move the needle forward.
If you use any of our libraries for work, see if your employers would be interested in donating. Any amount you can donate today to help us reach our goal would be greatly appreciated.

Our Ether wallet address: 0xe22b8979739d724343bd002f9f432f5990879901

![Donate](http://qrcoder.ru/code/?0xe22b8979739d724343bd002f9f432f5990879901&4&0)

## License

PlasmaSwiftLib is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/matterinc/PlasmaSwiftLib/blob/master/LICENSE) for details.
