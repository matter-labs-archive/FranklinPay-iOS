//
//  AcceptChequeVC+ModalViewDelegate.swift
//  Franklin
//
//  Created by Anton on 21/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension AcceptChequeController: ModalViewDelegate {
    func modalViewBeenDismissed(updateNeeded: Bool) {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = 0
                self.titleLabel.alpha = 0
                self.goToApp()
            })
        }
    }
    
    func modalViewAppeared() {
        if let wallets = try? walletsService.getAllWallets(), wallets.isEmpty {
            creatingWallet()
        }
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
                self.titleLabel.alpha = 1.0
            })
        }
    }
}
