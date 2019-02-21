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
import EthereumAddress

class AddContactController: BasicViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var enterButton: BasicBlueButton!
    @IBOutlet var textFields: [BasicTextField]!
    @IBOutlet weak var qrCodeButton: ScanButton!
    @IBOutlet weak var nameTextField: BasicTextField!
    @IBOutlet weak var addressTextField: BasicTextField!
    @IBOutlet weak var tapToQR: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Internal lets
    
    internal let alerts = Alerts()
    
    // MARK: - Public vars
    
    var initContact: Contact?
    var initAddress: String?
    
    // MARK: - Lazy vars
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Weak vars
    
    weak var delegate: ModalViewDelegate?
    
    // MARK: - Enums
    
    enum TextFieldsTags: Int {
        case name = 0
        case address = 1
    }
    
    // MARK: - Inits
    
    convenience init(contact: Contact) {
        self.init()
        self.initContact = contact
    }
    
    // MARK: - Lifesycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainSetup()
        self.setupTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showLabels(true)
        KeyboardAvoiding.avoidingView = self.contentView
    }
    
    // MARK: - Main setup
    
    func showLabels(_ show: Bool) {
        self.contactNameLabel.alpha = show ? 1 : 0
        self.addressLabel.alpha = show ? 1 : 0
        self.titleLabel.alpha = show ? 1 : 0
    }
    
    func setupTextField() {
        if initContact != nil {
            self.addressTextField.text = initContact?.address
            self.nameTextField.text = initContact?.name
        }
        self.nameTextField.delegate = self
        self.addressTextField.delegate = self
        self.nameTextField.tag = TextFieldsTags.name.rawValue
        self.addressTextField.tag = TextFieldsTags.address.rawValue
        nameTextField.returnKeyType = .next
        addressTextField.returnKeyType = .next
    }
    
    func mainSetup() {
        self.hideKeyboardWhenTappedAround()
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        self.navigationController?.navigationBar.isHidden = true
        enterButton.isEnabled = false
        updateEnterButtonAlpha()
        
        self.contentView.backgroundColor = Colors.background
        self.contentView.alpha = 1
        self.contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
        self.contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
        self.contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
        self.qrCodeButton.setImage(UIImage(named: "photo"), for: .normal)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(self.dismissView))
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
    }
    
    // MARK: - Screen updates
    
    internal func updateEnterButtonAlpha() {
        enterButton.alpha = enterButton.isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - Screen status
    
    internal func isEnterButtonEnabled(afterChanging textField: UITextField, with string: String) {
        enterButton.isEnabled = false
        let everyFieldIsOK: Bool
        switch textField {
        case addressTextField:
            everyFieldIsOK = !(nameTextField.text?.isEmpty ?? true) && !string.isEmpty
        default:
            everyFieldIsOK = !(addressTextField.text?.isEmpty ?? true) && !string.isEmpty
        }
        enterButton.isEnabled = everyFieldIsOK
    }
    
    // MARK: - Actions
    
    private func addContact(address: String, name: String) {
        let contact = Contact(address: address, name: name)
        do {
            if initContact != nil {
                try initContact?.deleteContact()
            }
            try contact.saveContact()
            self.dismissView()
        } catch let error {
            alerts.showErrorAlert(for: self, error: error) {
                self.dismissView()
            }
        }
    }
    
    // MARK: - Buttons actions
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed(updateNeeded: true)
    }

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
        guard EthereumAddress(address) != nil else {
            alerts.showErrorAlert(for: self, error: "Please, enter correct address", completion: nil)
            return
        }
        guard let name = nameTextField.text else {
            return
        }
        self.addContact(address: address, name: name)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismissView()
    }
}
