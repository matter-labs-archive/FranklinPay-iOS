//
//  SendMoneyController.swift
//  Franklin
//
//  Created by Anton Grigorev on 24/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import BlockiesSwift
import SwiftyGif
import EthereumAddress
import QRCodeReader
import BigInt

class SendMoneyController: BasicViewController {
    
    // MARK: - Enums
    
    enum TextFieldsTags: Int {
        case top = 0
        case middle = 1
        case bottom = 2
    }
    
    enum SendingScreenStatus {
        case start
        case searching
        case confirm
        case sending
        case ready
        case saving
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var topTextField: BasicTextField!
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var contactStack: UIStackView!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAddress: UILabel!
    @IBOutlet weak var tableView: BasicTableView!
    @IBOutlet weak var emptyContactsView: UIView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomTextField: BasicTextField!
    
    @IBOutlet weak var middleStackView: UIStackView!
    @IBOutlet weak var middleLabel: UILabel!
    @IBOutlet weak var middleTextField: BasicTextField!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readyIcon: UIImageView!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var mainButton: BasicWhiteButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var sendingGif: UIImageView!
    @IBOutlet weak var sendButton: BasicWhiteButton!
    
    // MARK: - Internal lets
    
    internal let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
    
    internal var searchStackOrigin: CGFloat = 0
    
    internal let contactsService = ContactsService()
    internal let alerts = Alerts()
    
    internal let reuseIdentifier = "ContactTableCell"
    internal let sectionInsets = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: 0,
                                              right: 0)
    internal let itemsPerRow: CGFloat = 3
    
    internal var contactsList: [Contact] = []
    internal var screenStatus: SendingScreenStatus = .start
    
    internal var chosenContact: Contact?
    var chosenToken: ERC20Token?
    internal var initAddress: String?
    
    // MARK: - Weak vars
    
    weak var delegate: ModalViewDelegate?
    weak var animationTimer: Timer?
    
    // MARK: - Lazy vars
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Inits
    
    convenience init(token: ERC20Token, address: String) {
        self.init()
        chosenToken = token
        initAddress = address
    }
    
    convenience init(token: ERC20Token) {
        self.init()
        chosenToken = token
    }
    
    // MARK: - Lifesycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        mainSetup()
        setupTextFields()
        setupTableView()
        //setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStart(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMiddleStackPosition()
        getAllContacts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chosenContact = nil
    }
    
    // MARK: - Main setup
    
    func setMiddleStackPosition() {
        searchStackOrigin = bottomStackView.frame.origin.y
    }
    
    func setupTextFields() {
        
        if initAddress != nil {
            middleTextField.text = initAddress
        }
        
        bottomTextField.delegate = self
        topTextField.delegate = self
        middleTextField.delegate = self
        
        bottomTextField.enablesReturnKeyAutomatically = true
        topTextField.enablesReturnKeyAutomatically = true
        middleTextField.enablesReturnKeyAutomatically = true
        
        topTextField.returnKeyType = .next
        middleTextField.returnKeyType = .next
        bottomTextField.returnKeyType = .next
        
        topTextField.tag = TextFieldsTags.top.rawValue
        bottomTextField.tag = TextFieldsTags.bottom.rawValue
        middleTextField.tag = TextFieldsTags.middle.rawValue
    }
    
    func getAllContacts() {
        do {
            let contacts = try contactsService.getAllContacts()
            updateContactsList(with: contacts)
        } catch {
            emptyContactsList()
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        tableView.tableFooterView = footerView
        
        let nibSearch = UINib.init(nibName: reuseIdentifier, bundle: nil)
        tableView.register(nibSearch, forCellReuseIdentifier: reuseIdentifier)
        contactsList.removeAll()
    }
    
    func mainSetup() {
        setupNavigation()
        setupBackground()
        setupContentView()
        setupGestures()
        setupGif()
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupBackground() {
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
    }
    
    func setupContentView() {
        contentView.backgroundColor = Colors.background
        contentView.alpha = 1
        contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
        contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
        contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
    }
    
    func setupGestures() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissView))
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
        
        let tapOnChosenContact: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showSearch(animated:)))
        tapOnChosenContact.cancelsTouchesInView = false
        contactStack.addGestureRecognizer(tapOnChosenContact)
    }
    
    func setupGif() {
        sendingGif.setGifImage(UIImage(gifName: "loading.gif"))
        sendingGif.loopCount = -1
        sendingGif.contentMode = .center
        sendingGif.isUserInteractionEnabled = false
    }
    
    // MARK: - Components setup with status
    
    func setTitle(text: String?, color: UIColor) {
        titleLabel.text = text
        titleLabel.textColor = color
    }
    
    func setBottomLabel(text: String?, color: UIColor, hidden: Bool) {
        shareLabel.text = text
        shareLabel.textColor = color
        shareLabel.alpha = hidden ? 0 : 1
    }
    
    func setCollectionView(hidden: Bool) {
        tableView.alpha = hidden ? 0 : 1
        tableView.isUserInteractionEnabled = !hidden
    }
    
    func setBottomButton(text: String?, imageName: String?, backgroundColor: UIColor, textColor: UIColor, hidden: Bool, borderNeeded: Bool) {
        mainButton.setTitle(text, for: .normal)
        mainButton.changeColorOn(background: backgroundColor, text: textColor)
        mainButton.setImage(UIImage(named: imageName ?? ""), for: .normal)
        mainButton.layer.borderWidth = borderNeeded ? 1 : 0
        mainButton.alpha = hidden ? 0 : 1
        mainButton.isUserInteractionEnabled = !hidden
    }
    
    func setTopButton(text: String?, imageName: String?, backgroundColor: UIColor, textColor: UIColor, hidden: Bool, borderNeeded: Bool) {
        sendButton.setTitle(text, for: .normal)
        sendButton.changeColorOn(background: backgroundColor, text: textColor)
        sendButton.setImage(UIImage(named: imageName ?? ""), for: .normal)
        sendButton.layer.borderWidth = borderNeeded ? 1 : 0
        sendButton.alpha = hidden ? 0 : 1
        sendButton.isUserInteractionEnabled = !hidden
    }
    
    func setTopStack(hidden: Bool, interactive: Bool, placeholder: String?, labelText: String?, resetText: Bool = false, keyboardType: UIKeyboardType = .decimalPad) {
        topLabel.text = labelText
        topTextField.placeholder = placeholder
        topStackView.alpha = hidden ? 0 : 1
        topStackView.isUserInteractionEnabled = interactive
        topTextField.keyboardType = keyboardType
        if resetText {
            topTextField.text = nil
        }
    }
    
    func setBottomStack(hidden: Bool, interactive: Bool, placeholder: String?, labelText: String?, position: CGFloat) {
        bottomLabel.text = labelText
        bottomTextField.placeholder = placeholder
        bottomStackView.alpha = hidden ? 0 : 1
        bottomStackView.isUserInteractionEnabled = interactive
        bottomStackView.frame.origin.y = position
    }
    
    func setMiddleStack(hidden: Bool, interactive: Bool, placeholder: String?, labelText: String?) {
        middleLabel.text = labelText
        middleTextField.placeholder = placeholder
        middleStackView.alpha = hidden ? 0 : 1
        middleStackView.isUserInteractionEnabled = interactive
    }
    
    func setContactStack(hidden: Bool, interactive: Bool, contact: Contact?, labelText: String?) {
        contactLabel.text = labelText
        chosenContact = contact
        contactStack.alpha = hidden ? 0 : 1
        contactStack.isUserInteractionEnabled = interactive
        let blockies = Blockies(seed: contact?.address,
                                size: 10,
                                scale: 100)
        let img = blockies.createImage()
        contactImage.image = img
        contactImage.layer.cornerRadius = Constants.CollectionCell.Image.cornerRadius
        contactImage.clipsToBounds = true
        guard let contactAddressString = contact?.address else {
            return
        }
        contactAddress.text = contactAddressString
        guard let contactNameString = contact?.name else {
            return
        }
        contactName.text = contactNameString
    }
    
    func setSeparator(hidden: Bool) {
        separatorView.alpha = hidden ? 0 : 1
    }
    
    func setReadyIcon(hidden: Bool) {
        readyIcon.alpha = hidden ? 0 : 1
        readyIcon.transform = hidden ? CGAffineTransform(scaleX: 1, y: 1) : CGAffineTransform(scaleX: 2, y: 2)
    }
    
    func showGif(_ show: Bool) {
        sendingGif.alpha = show ? 1 : 0
    }
    
    // MARK: - Timer mock for plasma animation
    
    @objc func fireTimer() {
        animationTimer?.invalidate()
        showReady(animated: true)
    }
    
    // MARK: - Data verifications
    
    func checkAmountAndNotifyIfError() -> Bool {
        guard let text = topTextField.text else {
            topTextField.text = nil
            topTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        let textWithDot = text.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(textWithDot) else {
            topTextField.text = nil
            topTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        guard amount > 0 else {
            topTextField.text = nil
            topTextField.attributedPlaceholder = NSAttributedString(string: "Should be more",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        guard amount <= Double(chosenToken?.balance ?? "0.0") ?? 0.0 else {
            alerts.showErrorAlert(for: self, error: "Enter less amount", completion: nil)
            return false
        }
        return true
    }
    
    func checkMoreThenOneNull(text: String) -> Bool {
        var wrong = false
        if text.count > 1 {
            wrong = text[0] == "0" && text[1] == "0"
        }
        return !wrong
    }
    
    func check18afterDot(text: String) -> Bool {
        let isNumeric = text.isEmpty || (Double(text) != nil)
        let numberOfDots = text.components(separatedBy: ".").count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = text.index(of: ".") {
            numberOfDecimalDigits = text.distance(from: dotIndex, to: text.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        
        let result = isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 18
        return result
    }
    
    func check18afterComma(text: String) -> Bool {
        let isNumeric = text.isEmpty || (Double(textWithComma: text) != nil)
        let numberOfDots = text.components(separatedBy: ",").count - 1
        
        let numberOfDecimalDigits: Int
        if let dotIndex = text.index(of: ",") {
            numberOfDecimalDigits = text.distance(from: dotIndex, to: text.endIndex) - 1
        } else {
            numberOfDecimalDigits = 0
        }
        
        let result = isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 18
        return result
    }
    
    func checkAddressAndCreateContact() -> Bool {
        guard let address = middleTextField.text, !address.isEmpty else {
            middleTextField.text = nil
            middleTextField.attributedPlaceholder = NSAttributedString(string: "Please, enter address",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return false
        }
        guard EthereumAddress(address) != nil else {
            alerts.showErrorAlert(for: self, error: "Please, enter correct address", completion: nil)
            return false
        }
        let contact = Contact(address: address, name: "")
        chosenContact = contact
        return true
    }
    
    // MARK: - Buttons actions
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed(updateNeeded: true)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismissView()
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        switch screenStatus {
        case .start:
            alerts.showErrorAlert(for: self, error: "Coming soon", completion: nil)
            //            guard let text = amountTextField.text else {
            //                amountTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
            //                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            //                return
            //            }
            //            guard let amount = Float(text) else {
            //                amountTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
            //                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            //                return
            //            }
            //            guard amount > 0 else {
            //                amountTextField.attributedPlaceholder = NSAttributedString(string: "Should be more",
            //                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            //                return
            //            }
            //
            //            let stringToShare = "I have sent you a cheque of \(text)"
            //
            //            let itemsToShare = [ stringToShare ]
            //            let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            //            activityViewController.popoverPresentationController?.sourceView = view // so that iPads won't crash
            //            // exclude some activity types from the list (optional)
            //            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.markupAsPDF ]
        //            present(activityViewController, animated: true, completion: nil)
        case .searching:
            showStart(animated: true)
        case .confirm:
            if checkAmountAndNotifyIfError() {
                showSending(animated: true)
            }
        case .ready:
            dismissView()
        case .sending:
            dismissView()
        case .saving:
            dismissView()
        }
    }
    
    @IBAction func sendToAddress(_ sender: BasicWhiteButton) {
        switch screenStatus {
        case .start:
            if checkAmountAndNotifyIfError(), checkAddressAndCreateContact() {
                showSending(animated: true)
            }
        case .searching:
            addContact()
        case .ready:
            showSaving(animated: true)
        case .saving:
            saveContact()
        default:
            dismissView()
        }
    }
    
    func saveContact() {
        guard let text = topTextField.text else {
            topTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            return
        }
        let contact = Contact(address: (chosenContact?.address)!, name: text)
        do {
            try contact.saveContact()
            dismissView()
        } catch {
            dismissView()
        }
    }
    
    func addContact() {
        bottomTextField.endEditing(true)
        modalViewAppeared()
        let addContactController = AddContactController()
        addContactController.delegate = self
        addContactController.modalPresentationStyle = .overCurrentContext
        addContactController.view.layer.speed = Constants.ModalView.animationSpeed
        present(addContactController, animated: true, completion: nil)
    }
    
    @IBAction func qrScanTapped(_ sender: Any) {
        readerVC.delegate = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
        }
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
}
