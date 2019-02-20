//
//  WalletViewController+UISideMenuNavigationControllerDelegate.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import SideMenu

extension WalletViewController: UISideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) {
        modalViewAppeared()
    }
    
    func sideMenuWillDisappear(menu: UISideMenuNavigationController, animated: Bool) {
        modalViewBeenDismissed(updateNeeded: false)
    }
}
