//
//  WalletViewController+CardCellDelegate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension WalletViewController: CardCellDelegate {
    func cardInfoTapped(_ sender: CardCell) {
        guard let indexPathTapped = walletTableView.indexPath(for: sender) else {
            return
        }
        let wallet = tokensArray[indexPathTapped.row].inWallet
        modalViewAppeared()
        let publicKeyController = PublicKeyViewController(for: wallet)
        publicKeyController.delegate = self
        publicKeyController.modalPresentationStyle = .overCurrentContext
        publicKeyController.view.layer.speed = Constants.ModalView.animationSpeed
        tabBarController?.present(publicKeyController, animated: true, completion: nil)
    }
}
