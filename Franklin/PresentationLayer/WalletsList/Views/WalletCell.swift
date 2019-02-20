//
//  WalletCell.swift
//  DiveLane
//
//  Created by NewUser on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

protocol WalletCellDelegate : class {
    func walletInfoTapped(_ sender: WalletCell)
}

class WalletCell: UITableViewCell {

    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletBalance: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var selectedWalletIcon: UIImageView!
    weak var delegate: WalletCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bottomBackgroundView.backgroundColor = Colors.background
        self.topBackgroundView.backgroundColor = Colors.background
        self.topBackgroundView.layer.cornerRadius = 10
        self.walletName.textColor = Colors.textDarkGray
        self.walletAddress.textColor = Colors.textLightGray
        self.walletBalance.textColor = Colors.textDarkGray
        
        self.selectedWalletIcon.image = UIImage(named: "added")
    }

    func configureCell(model: TableWallet) {
        walletName.text = model.wallet.name
        walletAddress.text = model.wallet.address.hideExtraSymbolsInAddress()
        let balance = model.balanceUSD ?? "..."
        self.walletBalance.text = balance + " $"
        self.selectedWalletIcon.alpha = model.isSelected ? 1.0 : 0.0
    }
    
    @IBAction func infoTapped(_ sender: UIButton) {
        delegate?.walletInfoTapped(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.walletBalance.text = "-"
        self.walletName.text = "-"
        self.walletName.text = "-"
    }

}
