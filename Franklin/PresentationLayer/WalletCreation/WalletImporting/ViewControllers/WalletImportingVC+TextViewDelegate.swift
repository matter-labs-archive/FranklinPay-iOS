//
//  WalletImportingVC+TextViewDelegate.swift
//  Franklin
//
//  Created by Anton on 22/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension WalletImportingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeView = textView
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        activeView?.resignFirstResponder()
        activeView = nil
    }
}
