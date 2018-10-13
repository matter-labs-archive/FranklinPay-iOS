//
//  ViewControllerExtensions.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,
                selector: #selector(UIViewController.keyboardWillShowForResizing),
                name: Notification.Name.UIKeyboardWillShow,
                object: nil)
        NotificationCenter.default.addObserver(self,
                selector: #selector(UIViewController.keyboardWillHideForResizing),
                name: Notification.Name.UIKeyboardWillHide,
                object: nil)
    }

    @objc func keyboardWillShowForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
           let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                    y: self.view.frame.origin.y,
                    width: self.view.frame.width,
                    height: window.origin.y + window.height - keyboardSize.height)
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }

    @objc func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                    y: self.view.frame.origin.y,
                    width: self.view.frame.width,
                    height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }

    func topViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while (topController?.presentedViewController != nil) {
            topController = topController?.presentedViewController
        }
        return topController
    }
}
