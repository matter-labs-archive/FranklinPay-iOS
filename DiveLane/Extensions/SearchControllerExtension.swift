//
//  SearchControllerExtension.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

extension UISearchController {
    func hideKeyboardWhenTappedOutsideSearchBar(for controller: UIViewController) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UISearchController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        controller.view.addGestureRecognizer(tap)
    }

    @objc override func dismissKeyboard() {
        self.searchBar.endEditing(true)
    }
}
