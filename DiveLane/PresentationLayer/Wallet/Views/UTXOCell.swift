//
//  UTXOCell.swift
//  DiveLane
//
//  Created by Anton Grigorev on 09/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import Web3swift
import EthereumAddress

class UTXOCell: UITableViewCell {
    
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var valueInDollars: UILabel!
    @IBOutlet weak var blockNumber: UILabel!
    @IBOutlet weak var txNumber: UILabel!
    @IBOutlet weak var etherUtxo: UILabel!
    @IBOutlet weak var block: UILabel!
    @IBOutlet weak var txnumb: UILabel!
    
    var link: WalletViewController?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.firstMain
        self.topBackgroundView.backgroundColor = Colors.secondMain
        self.topBackgroundView.layer.cornerRadius = 10
        self.etherUtxo.textColor = Colors.textFirst
        self.etherUtxo.font = UIFont(name: Constants.font, size: Constants.basicFontSize) ?? UIFont.systemFont(ofSize: Constants.basicFontSize)
        self.value.textColor = Colors.textFirst
        self.value.font = UIFont(name: Constants.boldFont, size: Constants.basicFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.basicFontSize)
        self.valueInDollars.textColor = Colors.textSecond
        self.valueInDollars.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
        self.blockNumber.textColor = Colors.active
        self.blockNumber.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
        self.txNumber.textColor = Colors.active
        self.txNumber.font = UIFont(name: Constants.boldFont, size: Constants.smallFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.smallFontSize)
        self.block.textColor = Colors.textSecond
        self.block.font = UIFont(name: Constants.font, size: Constants.smallFontSize) ?? UIFont.systemFont(ofSize: Constants.smallFontSize)
        self.txnumb.textColor = Colors.textSecond
        self.txnumb.font = UIFont(name: Constants.font, size: Constants.smallFontSize) ?? UIFont.systemFont(ofSize: Constants.smallFontSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(utxo: TableUTXO) {
        let value = Web3Utils.formatToEthereumUnits(utxo.utxo.value,
                                                    toUnits: .eth,
                                                    decimals: 6,
                                                    decimalSeparator: ".")
        let valueInEth = value ?? "-"
        let blockNumber = String(utxo.utxo.blockNumber)
        let txNumber = String(utxo.utxo.transactionNumber)
        self.value.text = valueInEth
        self.blockNumber.text = blockNumber
        self.txNumber.text = txNumber
        
        DispatchQueue.global().async { [weak self] in
            let rateInDouble: Double
            if let rate = RatesState.shared().rates["ETH"] {
                rateInDouble = rate
            } else {
                guard let newRate = try? ERC20Token(ether: true).updateConversionRate() else {
                    self?.valueInDollars.text = "-"
                    return
                }
                rateInDouble = newRate
            }
            guard let v = value else {
                self?.valueInDollars.text = "-"
                return
            }
            guard let valueInDouble: Double = Double(v) else {
                self?.valueInDollars.text = "-"
                return
            }
            let convertedAmount = Double(round(100*(rateInDouble * valueInDouble))/100)
            let stringAmount =  String(convertedAmount)
            DispatchQueue.main.async {
                self?.valueInDollars.text = "$" + stringAmount
            }
        }
        self.changeSelectButton(isSelected: false)
    }
    
    func changeSelectButton(isSelected: Bool) {
        let button = selectButton(isSelected: isSelected)
        button.addTarget(self, action: #selector(handleMarkAsSelected), for: .touchUpInside)
        accessoryView = button
    }
    
    @objc private func handleMarkAsSelected() {
        link?.selectUTXO(cell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.value.text = "-"
        self.valueInDollars.text = "-"
        self.blockNumber.text = "-"
        self.txNumber.text = "-"
    }
    
}
