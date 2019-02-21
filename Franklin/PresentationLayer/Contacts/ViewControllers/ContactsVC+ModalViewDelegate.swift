//
//  ContactsVC+ModalViewDelegate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension ContactsViewController: ModalViewDelegate {
    func modalViewBeenDismissed(updateNeeded: Bool) {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: { [unowned self] in
                self.topViewForModalAnimation.alpha = 0
            })
        }
        if updateNeeded { getAllContacts() }
    }
    
    func modalViewAppeared() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: { [unowned self] in
                self.topViewForModalAnimation.alpha = 0.5
            })
        }
    }
}
