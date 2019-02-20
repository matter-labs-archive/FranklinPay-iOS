//
//  SettingsVC+ModalViewDelegate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension SettingsViewController: ModalViewDelegate {
    func modalViewBeenDismissed(updateNeeded: Bool) {
        //        DispatchQueue.main.async { [unowned self] in
        //            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
        //                topViewForModalAnimation.alpha = 0
        //            })
        //        }
    }
    
    func modalViewAppeared() {
        //        DispatchQueue.main.async { [unowned self] in
        //            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
        //                topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
        //            })
        //        }
    }
}
