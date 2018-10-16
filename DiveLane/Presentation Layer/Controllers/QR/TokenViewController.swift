//
//  TokenViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class TokenViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var tokenNameBalanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copiedLabel: UILabel!
    @IBOutlet weak var copyAddressButton: UIButton!
    @IBOutlet weak var sendTokenButton: UIButton!

    var tokenBalance: String?
    var wallet: KeyWalletModel?
    var token: ERC20TokenModel?

    convenience init(wallet: KeyWalletModel,
                     token: ERC20TokenModel,
                     tokenBalance: String) {
        self.init()
        self.wallet = wallet
        self.token = token
        self.tokenBalance = tokenBalance
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        qrImageView.image = generateQRCode(from: wallet?.address)
        addressLabel.text = wallet?.address.lowercased()
        tokenNameBalanceLabel.text = "Loading..."
        hideCopiedLabel(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Token"
        checkBalanceAndEnableSend()
    }

    func hideCopiedLabel(_ hidden: Bool = false) {
        copiedLabel.alpha = hidden ? 0.0 : 1.0
    }

    func checkBalanceAndEnableSend() {
        guard let balance = Float(tokenBalance!) else {
            disableSendButton()
            return
        }
        guard balance > 0 else {
            disableSendButton()
            return
        }
        enableSendButton()
    }

    func disableSendButton() {
        tokenNameBalanceLabel.text = "\(token?.symbol ?? ""): \(tokenBalance ?? "0")"
        sendTokenButton.isEnabled = false
        sendTokenButton.alpha = 0.5
    }

    func enableSendButton() {
        tokenNameBalanceLabel.text = "\(token?.symbol ?? ""): \(tokenBalance ?? "0")"
        sendTokenButton.isEnabled = true
        sendTokenButton.alpha = 1.0
    }

    func getBalance() {
        guard let token = token else {
            return
        }
        guard let wallet = wallet else {
            return
        }
        if token == ERC20TokenModel(isEther: true) {
            Web3SwiftService().getETHbalance(for: wallet) { [weak self] (result, error) in
                if error == nil && result != nil {
                    self?.tokenBalance = result!
                    self?.checkBalanceAndEnableSend()
                } else {
                    self?.getBalance()
                }
            }
        } else {
            Web3SwiftService().getERCBalance(for: token.address,
                    address: wallet.address) { [weak self] (result, error) in
                if error == nil && result != nil {
                    self?.tokenBalance = result!
                    self?.checkBalanceAndEnableSend()
                } else {
                    self?.getBalance()
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getBalance()
    }

    func generateQRCode(from string: String?) -> UIImage? {
        guard let string = string else {
            return nil
        }

        guard let code = Web3.EIP67Code(address: string)?.toString() else {
            return nil
        }

        let data = code.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    @IBAction func copyAddress(_ sender: UIButton) {
        UIPasteboard.general.string = wallet?.address

        DispatchQueue.main.async { [weak self] in
            self?.hideCopiedLabel(true)
            UIView.animate(withDuration: 1.0,
                    animations: {
                        self?.hideCopiedLabel(false)
                    }, completion: { _ in
                UIView.animate(withDuration: 2.0, animations: {
                    self?.hideCopiedLabel(true)
                })
            })
        }
    }

    @IBAction func sendToken(_ sender: UIButton) {
        guard let wallet = wallet else {
            return
        }
        guard let token = token else {
            return
        }
        let sendSettingsViewController = SendSettingsViewController(
                wallet: wallet,
                tokenBalance: tokenBalance ?? "",
                token: token)
        self.navigationController?.pushViewController(sendSettingsViewController, animated: true)
    }

}
