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

    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet weak var qrCodeButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Contact"
        self.hideKeyboardWhenTappedAround()
        enterButton.isEnabled = false
        updateEnterButtonAlpha()
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

        guard let address = addressTextField.text else {
            return
        }

        guard let name = nameTextField.text else {
            return
        }

        self.addContact(address: address, name: name)

    }

    private func addContact(address: String, name: String) {
        let contact = ContactModel(address: address, name: name)
        ContactsDatabase().saveContact(contact: contact) { (error) in
            guard error == nil else {return}
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func updateEnterButtonAlpha() {
        enterButton.alpha = enterButton.isEnabled ? 1.0 : 0.5
    }

    private func isEnterButtonEnabled(afterChanging textField: UITextField, with string: String) {

        enterButton.isEnabled = false

        switch textField {
        case addressTextField:
            let everyFieldIsOK = !(nameTextField.text?.isEmpty ?? true) && !string.isEmpty
            enterButton.isEnabled = everyFieldIsOK
        default:
            let everyFieldIsOK = !(addressTextField.text?.isEmpty ?? true) && !string.isEmpty
            enterButton.isEnabled = everyFieldIsOK
        }
    }

}

extension AddContactController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = enterButton.isEnabled ? UIReturnKeyType.done : .next
        textField.textColor = UIColor.blue
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let futureString = currentText.replacingCharacters(in: range, with: string) as String

        isEnterButtonEnabled(afterChanging: textField, with: futureString)

        updateEnterButtonAlpha()

        textField.returnKeyType = enterButton.isEnabled ? UIReturnKeyType.done : .next

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done && enterButton.isEnabled {
            addContactButtonTapped(self)
        } else if textField.returnKeyType == .next {
            let index = textFields.index(of: textField) ?? 0
            let nextIndex = (index == textFields.count - 1) ? 0 : index + 1
            textFields[nextIndex].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}

extension AddContactController: QRCodeReaderViewControllerDelegate {

    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        addressTextField.text = result.value
        if !(nameTextField.text?.isEmpty ?? true) {
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
