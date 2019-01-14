//
//  AddContactController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader

class AddContactController: UIViewController {

    @IBOutlet weak var enterButton: BasicSelectedButton!
    @IBOutlet var textViews: [BasicTextView]!
    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var nameTextView: BasicTextView!
    @IBOutlet weak var addressTextView: BasicTextView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var tapToQR: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var activeView: UITextView?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    let alerts = Alerts()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func mainSetup() {
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Add Contact"
        enterButton.isEnabled = false
        updateEnterButtonAlpha()
        
        self.view.backgroundColor = Colors.firstMain
        self.scrollView.backgroundColor = Colors.firstMain
        self.contentView.backgroundColor = Colors.firstMain
        self.tapToQR.textColor = Colors.secondMain
        self.qrCodeButton.setImage(UIImage(named: "qr"), for: .normal)
        self.nameTextView.delegate = self
        self.addressTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        guard activeView != nil else {
            return
        }
        activeView?.resignFirstResponder()
        activeView = nil
    }

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }

        return QRCodeReaderViewController(builder: builder)
    }()

    @IBAction func qrScanTapped(_ sender: Any) {
        readerVC.delegate = self

        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
        }
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }

    @IBAction func addContactButtonTapped(_ sender: Any) {

        guard let address = addressTextView.text else {
            return
        }

        guard let name = nameTextView.text else {
            return
        }

        self.addContact(address: address, name: name)

    }

    private func addContact(address: String, name: String) {
        let contact = Contact(address: address, name: name)
        do {
            try contact.saveContact()
            self.navigationController?.popViewController(animated: true)
        } catch let error {
            alerts.showErrorAlert(for: self, error: error) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func updateEnterButtonAlpha() {
        enterButton.alpha = enterButton.isEnabled ? 1.0 : 0.5
    }

    private func isEnterButtonEnabled(afterChanging textView: UITextView, with string: String) {
        enterButton.isEnabled = false
        let everyViewIsOK: Bool
        switch textView {
        case addressTextView:
            everyViewIsOK = !(nameTextView.text?.isEmpty ?? true) && !string.isEmpty
        default:
            everyViewIsOK = !(addressTextView.text?.isEmpty ?? true) && !string.isEmpty
        }
        enterButton.isEnabled = everyViewIsOK
    }

}

extension AddContactController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeView = textView
        lastOffset = self.scrollView.contentOffset
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeView?.resignFirstResponder()
        activeView = nil
        if activeView?.returnKeyType == .done && enterButton.isEnabled {
            addContactButtonTapped(self)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = (textView.text ?? "") as NSString
        let futureString = currentText.replacingCharacters(in: range, with: text) as String
        
        isEnterButtonEnabled(afterChanging: textView, with: futureString)
        
        updateEnterButtonAlpha()
        
        textView.returnKeyType = enterButton.isEnabled ? UIReturnKeyType.done : .next
        
        return true
    }
}

extension AddContactController: QRCodeReaderViewControllerDelegate {

    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        addressTextView.text = result.value
        if !(nameTextView.text?.isEmpty ?? true) {
            enterButton.isEnabled = true
            enterButton.alpha = 1
        }
        dismiss(animated: true, completion: nil)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }

}

extension AddContactController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.contentHeight.constant += self.keyboardHeight
            })
            
            // move if keyboard hide input field
            let distanceToBottom = self.scrollView.frame.size.height - (activeView?.frame.origin.y)! - (activeView?.frame.size.height)!
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.contentHeight.constant -= self.keyboardHeight
            
            self.scrollView.contentOffset = self.lastOffset
        }
        
        keyboardHeight = nil
    }
}
