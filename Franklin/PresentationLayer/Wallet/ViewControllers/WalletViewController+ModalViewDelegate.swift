//
//  WalletModalViewDelegate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension WalletViewController: ModalViewDelegate {
    func modalViewBeenDismissed(updateNeeded: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if updateNeeded { self.setTokensList() }
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: { [unowned self] in
                self.topViewForModalAnimation.alpha = 0
            })
        }
    }
    
    func modalViewAppeared() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: { [unowned self] in
                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
            })
        }
    }
}
