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

class AddContactController: BasicViewController {

    @IBOutlet weak var enterButton: BasicBlueButton!
    @IBOutlet var textViews: [BasicTextView]!
    @IBOutlet weak var qrCodeButton: ScanButton!
    @IBOutlet weak var nameTextView: BasicTextView!
    @IBOutlet weak var addressTextView: BasicTextView!
    @IBOutlet weak var tapToQR: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    let alerts = Alerts()
    
    weak var delegate: ModalViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        KeyboardAvoiding.avoidingView = self.contentView
    }
    
    func mainSetup() {
        self.navigationController?.navigationBar.isHidden = true
        enterButton.isEnabled = false
        updateEnterButtonAlpha()
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        self.contentView.backgroundColor = Colors.background
        self.contentView.alpha = 1
        self.contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
        self.contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
        self.contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
        self.qrCodeButton.setImage(UIImage(named: "photo"), for: .normal)
        self.nameTextView.delegate = self
        self.addressTextView.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(self.dismissView))
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(self.dismissKeyboard))
        dismissKeyboard.cancelsTouchesInView = false
        self.contentView.addGestureRecognizer(dismissKeyboard)
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed()
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
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismissView()
    }
    
    private func addContact(address: String, name: String) {
        let contact = Contact(address: address, name: name)
        do {
            try contact.saveContact()
            self.dismissView()
        } catch let error {
            alerts.showErrorAlert(for: self, error: error) {
                self.dismissView()
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
        reader.dismiss(animated: true, completion: nil)
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
}
