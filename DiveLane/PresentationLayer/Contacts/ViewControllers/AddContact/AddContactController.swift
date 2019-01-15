//
//  AddContactController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 16.10.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader
import IHKeyboardAvoiding

class AddContactController: UIViewController {

    @IBOutlet weak var enterButton: BasicSelectedButton!
    @IBOutlet var textViews: [BasicTextView]!
    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var nameTextView: BasicTextView!
    @IBOutlet weak var addressTextView: BasicTextView!
    @IBOutlet weak var tapToQR: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    let alerts = Alerts()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        KeyboardAvoiding.avoidingView = self.contentView
    }
    
    func mainSetup() {
        self.navigationController?.navigationBar.isHidden = false
        self.title = "Add Contact"
        enterButton.isEnabled = false
        updateEnterButtonAlpha()
        
        self.view.backgroundColor = Colors.firstMain
        self.contentView.backgroundColor = Colors.firstMain
        self.tapToQR.textColor = Colors.secondMain
        self.qrCodeButton.setImage(UIImage(named: "qr"), for: .normal)
        self.nameTextView.delegate = self
        self.addressTextView.delegate = self
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
