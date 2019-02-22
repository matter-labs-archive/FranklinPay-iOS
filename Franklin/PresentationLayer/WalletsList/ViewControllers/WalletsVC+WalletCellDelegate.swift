//
//  WalletsVC+WalletCellDelegate.swift
//  Franklin
//
//  Created by Anton on 22/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension WalletsViewController: WalletCellDelegate {
    func walletInfoTapped(_ sender: WalletCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let wallet = wallets[tappedIndexPath.row]
        showInfoActions(for: wallet)
    }
}
