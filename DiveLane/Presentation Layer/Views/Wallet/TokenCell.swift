//
//  TokenCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import web3swift

class TokenCell: UITableViewCell {

    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var tokenShortName: UILabel!
    @IBOutlet weak var tokenIcon: UIImageView!
    @IBOutlet weak var tokenAddress: UILabel!
    @IBOutlet weak var balanceInDollars: UILabel!

    var link: WalletViewController?

    let keysService: KeysService = KeysService()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(token: ERC20TokenModel?, forWallet: KeyWalletModel, withConversionRate: Double = 0) {

        guard let token = token else {
            return
        }

        var networkName: String?
        guard CurrentNetwork.currentNetwork != nil else {
            return
        }
        switch CurrentNetwork.currentNetwork! {
        case .Rinkeby: networkName = "Rinkeby"
        case .Ropsten: networkName = "Ropsten"
        case .Mainnet: networkName = "Mainnet"
        case .Kovan: networkName = "Kovan"
        case .Custom: networkName = ""
        }
        self.tokenShortName.text = token.symbol.uppercased()

        if token == ERC20TokenModel(name: "Ether",
                address: "",
                decimals: "18",
                symbol: "Eth") {
            self.tokenAddress.text = "Wallet: \(forWallet.address)"
            self.balance.text = "Loading..."
            Web3SwiftService().getETHbalance(for: forWallet) { [weak self] (result, _) in
                DispatchQueue.main.async {
                    self?.balance.text = result ?? ""

                    let convertedAmount = withConversionRate == 0.0 ?
                        NSLocalizedString("No data from CryptoCompare", comment: "") :
                        String(format: NSLocalizedString("$%f at the rate of CryptoCompare", comment: ""),
                               withConversionRate * Double(result ?? "0")!)
                    self?.balanceInDollars.text = convertedAmount
                }
            }
        } else {
            self.tokenAddress.text = "Token: \(token.address)"
            self.balance.text = "Loading..."
            Web3SwiftService().getERCBalance(for: token.address,
                    address: forWallet.address) { [weak self] (result, _) in
                DispatchQueue.main.async {
                    self?.balance.text = result ?? ""

                    let convertedAmount = withConversionRate == 0.0 ?
                        NSLocalizedString("No data from CryptoCompare", comment: "") :
                        String(format: NSLocalizedString("$%f at the rate of CryptoCompare", comment: ""),
                               withConversionRate * Double(result ?? "0")!)
                    self?.balanceInDollars.text = convertedAmount
                }
            }
        }

        //select token
        let starButton = UIButton(type: .system)
        starButton.setImage(UIImage(named: "SuccessIcon"), for: .normal)
        starButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)

        starButton.tintColor = .lightGray
        starButton.addTarget(self, action: #selector(handleMarkAsSelected), for: .touchUpInside)

        accessoryView = starButton
    }

    @objc private func handleMarkAsSelected() {
        link?.selectToken(cell: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.balance.text = ""
        self.tokenShortName.text = ""
        self.tokenAddress.text = ""
        self.tokenIcon.image = UIImage(named: "ether")
    }
}
