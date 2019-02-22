//
//  AcceptChequeFormController.swift
//  Franklin
//
//  Created by Anton Grigorev on 28/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import EthereumAddress
import BlockiesSwift
import SwiftyGif

class AcceptChequeFormController: BasicViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var upperConfirmation: UIStackView!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAddress: UILabel!
    @IBOutlet weak var fromStack: UIStackView!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var successIcon: UIImageView!
    @IBOutlet weak var processAnimation: UIImageView!
    @IBOutlet weak var topButton: BasicWhiteButton!
    @IBOutlet weak var bottomButton: BasicWhiteButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var contactNameField: BasicTextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountStack: UIStackView!
    
    // MARK: - Enums
    
    enum RedeemScreenStatus {
        case start
        case accepting
        case accepted
        case save
    }
    
    // MARK: - Internal lets
    
    internal let alerts = Alerts()
    internal let contactsService = ContactsService()
    internal var screenStatus: RedeemScreenStatus = .start
    
    internal let cheque: PlasmaCode
    
    // MARK: - Weak vars
    
    weak var animationTimer: Timer?
    weak var delegate: ModalViewDelegate?
    
    // MARK: - Inits
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(cheque: PlasmaCode) {
        self.cheque = cheque
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - Lifesycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        mainSetup()
        setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStart(animated: false)
        setupContact()
    }
    
    // MARK: - Main setup
    
    func setupTextFields() {
        contactNameField.delegate = self
    }
    
    func setupContact() {
        amountLabel.text = cheque.amount + " ETH"
        let name = isContactExists(address: cheque.address) ?? "Unknown contact"
        contactName.text = name
        contactAddress.text = cheque.address.address
        let blockies = Blockies(seed: cheque.address.address, size: 5, scale: 4, color: Colors.mainGreen, bgColor: Colors.mostLightGray, spotColor: Colors.mainBlue)
        let img = blockies.createImage()
        contactImage.layer.cornerRadius = Constants.TableContact.cornerRadius
        contactImage.clipsToBounds = true
        contactImage.image = img
        contactAddress.font = UIFont(name: Constants.TableContact.font,
                                          size: Constants.TableContact.minimumFontSize)
        //contactAddress.adjustsFontSizeToFitWidth = true
        contactAddress.fitTextToBounds()
    }
    
    func mainSetup() {
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        
        contentView.backgroundColor = Constants.ModalView.ContentView.backgroundColor
        contentView.alpha = 1
        contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
        contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
        contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(dismissView))
        tap.cancelsTouchesInView = false
        
        backgroundView.addGestureRecognizer(tap)
        
        processAnimation.setGifImage(UIImage(gifName: "loading.gif"))
        processAnimation.loopCount = -1
        processAnimation.contentMode = .center
        processAnimation.isUserInteractionEnabled = false
    }
    
    // MARK: - Timer mock
    
    @objc func fireTimer() {
        animationTimer?.invalidate()
        showAccepted(animated: true)
    }
    
    // MARK: - Screen status
    
    func showStart(animated: Bool) {
        screenStatus = .start
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
                self.titleLabel.text = "You got a cheque!"
                self.processAnimation.alpha = 0
                self.successIcon.alpha = 0
                self.topButton.alpha = 0
                self.bottomButton.alpha = 1
                self.bottomButton.setTitle("Redeem cheque", for: .normal)
                self.bottomButton.changeColorOn(background: Colors.mainBlue, text: Colors.textWhite)
                self.bottomButton.setImage(UIImage(named: "checked"), for: .normal)
                self.infoLabel.alpha = 0
                self.fromStack.alpha = 1
                self.amountStack.alpha = 1
                self.upperConfirmation.alpha = 0
                self.contactNameField.alpha = 0
                self.contactNameField.isUserInteractionEnabled = false
                self.fromLabel.text = "From:"
        }
    }
    
    func showAccepting(animated: Bool) {
        screenStatus = .accepting
        updateFranklinBalance()
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0, animations: { [unowned self] in
                self.titleLabel.text = "You got a cheque!"
                self.processAnimation.alpha = 1
                self.successIcon.alpha = 0
                self.topButton.alpha = 0
                self.bottomButton.alpha = 0
                self.infoLabel.alpha = 0
                self.fromStack.alpha = 1
                self.amountStack.alpha = 1
                self.upperConfirmation.alpha = 0
                self.contactNameField.alpha = 0
                self.contactNameField.isUserInteractionEnabled = false
        }) { [unowned self] (completed) in
            if completed {
                self.accepting()
            }
        }
    }
    
    @objc func showAccepted(animated: Bool) {
        screenStatus = .accepted
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
                self.successIcon.alpha = 1
                self.successIcon.transform = CGAffineTransform(scaleX: 3, y: 3)
        }
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
                self.titleLabel.text = "Cheque accepted!"
                self.titleLabel.textColor = Colors.mainGreen
                self.processAnimation.alpha = 0
                self.topButton.alpha = self.isContactExists(address: self.cheque.address) != nil ? 0 : 1
                self.bottomButton.alpha = 1
                self.topButton.setTitle("Save as contact", for: .normal)
                self.topButton.changeColorOn(background: Colors.mainBlue, text: Colors.textWhite)
                self.topButton.setImage(UIImage(named: "save-button"), for: .normal)
                self.bottomButton.setTitle("Close", for: .normal)
                self.bottomButton.changeColorOn(background: Colors.background, text: Colors.mainBlue)
                self.bottomButton.setImage(nil, for: .normal)
                self.infoLabel.alpha = 0
                self.fromStack.alpha = 1
                self.amountStack.alpha = 1
                self.upperConfirmation.alpha = 0
                self.contactNameField.alpha = 0
                self.contactNameField.isUserInteractionEnabled = false
        }
    }
    
    @objc func showSave(animated: Bool) {
        screenStatus = .save
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
                self.titleLabel.text = "Save as contact"
                self.titleLabel.textColor = Colors.mainBlue
                self.successIcon.alpha = 0
                self.processAnimation.alpha = 0
                self.topButton.alpha = 0
                self.bottomButton.alpha = 1
                self.bottomButton.setTitle("Save", for: .normal)
                self.bottomButton.changeColorOn(background: Colors.mainBlue, text: Colors.textWhite)
                self.bottomButton.setImage(UIImage(named: "checked"), for: .normal)
                self.infoLabel.alpha = 1
                self.fromStack.alpha = 0
                self.amountStack.alpha = 0
                self.upperConfirmation.alpha = 1
                self.contactNameField.alpha = 1
                self.contactNameField.isUserInteractionEnabled = true
                self.fromLabel.text = "Contact name:"
        }
    }
    
    func accepting() {
        animationTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
    
    // MARK: - Checks
    
    func isContactExists(address: EthereumAddress) -> String? {
        do {
            let contact = try contactsService.getContact(address: cheque.address)
            return contact.name
        } catch {
            return nil
        }
    }
    
    // MARK: - Actions
    
    func updateFranklinBalance() {
        let currentNetwork = CurrentNetwork.currentNetwork
        guard let currentWallet = CurrentWallet.currentWallet else {return}
        guard let tokens = try? currentWallet.getAllTokens(network: currentNetwork) else {return}
        for token in tokens {
            if token == ERC20Token(franklin: true) {
                guard let balance = token.balance else {return}
                guard var currBalance = Double(balance) else {return}
                guard let chequeAmount = Double(cheque.amount) else {return}
                currBalance += chequeAmount
                let stringCurrBalance = String(currBalance)
                //                do {
                //                    try currentWallet.delete(token: token, network: currentNetwork)
                //                    let fr = Franklin()
                //                    fr.balance = stringCurrBalance
                //                    try currentWallet.add(token: fr, network: currentNetwork)
                //                } catch {
                //                    continue
                //                }
                do {
                    try token.saveBalance(in: currentWallet, network: currentNetwork, balance: stringCurrBalance)
                } catch {
                    continue
                }
            }
        }
    }
    
    func saveContact() {
        guard let name = contactNameField.text else {
            return
        }
        let contact = Contact(address: cheque.address.address, name: name)
        do {
            try contact.saveContact()
            dismissView()
        } catch let error {
            alerts.showErrorAlert(for: self, error: error) { [unowned self] in
                self.dismissView()
            }
        }
    }
    
    // MARK: - Button actions
    
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed(updateNeeded: false)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismissView()
    }
    
    @IBAction func topButtonAction(_ sender: UIButton) {
        showSave(animated: true)
    }
    
    @IBAction func bottomButtonAction(_ sender: UIButton) {
        switch screenStatus {
        case .start:
            showAccepting(animated: true)
        case .accepted:
            dismissView()
        case .save:
            saveContact()
        case .accepting:
            print("acceptin")
        }
    }
    
}
