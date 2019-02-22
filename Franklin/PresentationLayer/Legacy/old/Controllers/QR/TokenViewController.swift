////
////  TokenViewController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 08/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//import Web3swift
//import BigInt
//import EthereumAddress
//
//class TokenViewController: UIViewController {
//
//    @IBOutlet weak var qrImageView: UIImageView!
//    @IBOutlet weak var tokenNameBalanceLabel: UILabel!
//    @IBOutlet weak var addressLabel: UILabel!
//    @IBOutlet weak var copiedLabel: UILabel!
//    @IBOutlet weak var copyAddressButton: UIButton!
//    @IBOutlet weak var sendTokenButton: UIButton!
//    @IBOutlet weak var plasmaDeposit: UIButton!
//    
//    var tokenBalance: String?
//    var wallet: WalletModel?
//    var token: ERC20TokenModel?
//
//    convenience init(wallet: WalletModel,
//                     token: ERC20TokenModel,
//                     tokenBalance: String) {
//        self.init()
//        self.wallet = wallet
//        self.token = token
//        self.tokenBalance = tokenBalance
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let network = CurrentNetwork.currentNetwork
//        if let token = self.token, token == ERC20TokenModel(isEther: true), (network.chainID == Networks.Rinkeby.chainID || network.chainID == Networks.Mainnet.chainID ) {
//            self.plasmaDeposit.isHidden = false
//        } else {
//            self.plasmaDeposit.isHidden = true
//        }
//        qrImageView.image = generateQRCode(from: wallet?.address)
//        addressLabel.text = wallet?.address.lowercased()
//        tokenNameBalanceLabel.text = "Loading..."
//        hideCopiedLabel(true)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.title = "Token"
//        checkBalanceAndEnableSend()
//    }
//
//    func hideCopiedLabel(_ hidden: Bool = false) {
//        copiedLabel.alpha = hidden ? 0.0 : 1.0
//    }
//
//    func checkBalanceAndEnableSend() {
//        guard let balance = Float(tokenBalance!) else {
//            disableButtons()
//            return
//        }
//        guard balance > 0 else {
//            disableButtons()
//            return
//        }
//        enableButtons()
//    }
//
//    func disableButtons() {
//        tokenNameBalanceLabel.text = "\(token?.symbol ?? ""): \(tokenBalance ?? "0")"
//        sendTokenButton.isEnabled = false
//        sendTokenButton.alpha = 0.5
//        plasmaDeposit.isEnabled = false
//        plasmaDeposit.alpha = 0.5
//    }
//
//    func enableButtons() {
//        tokenNameBalanceLabel.text = "\(token?.symbol ?? ""): \(tokenBalance ?? "0")"
//        sendTokenButton.isEnabled = true
//        sendTokenButton.alpha = 1.0
//        plasmaDeposit.isEnabled = true
//        plasmaDeposit.alpha = 1.0
//    }
//
//    func getBalance() {
//        guard let token = token else {
//            return
//        }
//        guard let wallet = wallet else {
//            return
//        }
//        do {
//            if token == ERC20TokenModel(isEther: true) {
//                let balance = try Web3Service().getETHbalance(for: wallet)
//                self.tokenBalance = balance
//                self.checkBalanceAndEnableSend()
//                
//            } else {
//                let balance = try Web3Service().getERC20balance(for: wallet, token: token)
//                self.tokenBalance = balance
//                self.checkBalanceAndEnableSend()
//            }
//        } catch {
//            self.getBalance()
//        }
//        
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.getBalance()
//    }
//
//    func generateQRCode(from string: String?) -> UIImage? {
//        guard let string = string else {
//            return nil
//        }
//
//        guard let code = Web3.EIP67Code(address: string)?.toString() else {
//            return nil
//        }
//
//        let data = code.data(using: String.Encoding.ascii)
//
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//            let transform = CGAffineTransform(scaleX: 3, y: 3)
//
//            if let output = filter.outputImage?.transformed(by: transform) {
//                return UIImage(ciImage: output)
//            }
//        }
//
//        return nil
//    }
//
//    @IBAction func copyAddress(_ sender: UIButton) {
//        UIPasteboard.general.string = wallet?.address
//
//        DispatchQueue.main.async { [weak self] in
//            self?.hideCopiedLabel(true)
//            UIView.animate(withDuration: 1.0,
//                    animations: {
//                        self?.hideCopiedLabel(false)
//                    }, completion: { _ in
//                UIView.animate(withDuration: 2.0, animations: {
//                    self?.hideCopiedLabel(true)
//                })
//            })
//        }
//    }
//
//    @IBAction func sendToken(_ sender: UIButton) {
//        guard let wallet = wallet else {
//            return
//        }
//        do {
//            try WalletsService().selectWallet(wallet: wallet)
//        } catch {
//            return
//        }
//        guard let token = token else {
//            return
//        }
//        let sendSettingsViewController = SendSettingsViewController(
//                tokenBalance: tokenBalance ?? "",
//                token: token)
//        self.navigationController?.pushViewController(sendSettingsViewController, animated: true)
//    }
//    
//    @IBAction func makePlasmaDeposit(_ sender: UIButton) {
//        guard let wallet = wallet else {
//            return
//        }
//        do {
//            try WalletsService().selectWallet(wallet: wallet)
//        } catch {
//            return
//        }
//        guard let token = token else {
//            return
//        }
//        let sendSettingsViewController = SendSettingsViewController(PlasmaContract.plasmaAddress,
//                                                                    tokenBalance: tokenBalance ?? "",
//                                                                    token: token)
//        self.navigationController?.pushViewController(sendSettingsViewController, animated: true)
//    }
//
//}
