//
//  WalletTableViewHeaderDelegate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension WalletViewController: TableHeaderDelegate {
    func didPressAdd(sender: UIButton) {
        modalViewAppeared()
        guard let wallet = CurrentWallet.currentWallet else {return}
        let sendMoneyVC = SearchTokenViewController(for: wallet)
        sendMoneyVC.delegate = self
        sendMoneyVC.modalPresentationStyle = .overCurrentContext
        sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
        tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
    }
}
