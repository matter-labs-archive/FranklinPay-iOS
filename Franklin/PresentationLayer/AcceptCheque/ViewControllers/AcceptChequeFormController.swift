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
    
    enum RedeemScreenStatus {
        case start
        case accepting
        case accepted
        case save
    }
    
    let alerts = Alerts()
    weak var delegate: ModalViewDelegate?
    let contactsService = ContactsService()
    var screenStatus: RedeemScreenStatus = .start
    
    let cheque: PlasmaCode
    
    weak var animationTimer: Timer?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(cheque: PlasmaCode) {
        self.cheque = cheque
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.mainSetup()
        self.setupTextFields()
    }
    
    @objc func fireTimer() {
        animationTimer?.invalidate()
        self.showAccepted(animated: true)
    }
    
    func accepting() {
        self.animationTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStart(animated: false)
        setupContact()
    }
    
    func setupTextFields() {
        contactNameField.delegate = self
    }
    
    func isContactExists(address: EthereumAddress) -> String? {
        do {
            let contact = try contactsService.getContact(address: cheque.address)
            return contact.name
        } catch {
            return nil
        }
    }
    
    func setupContact() {
        self.amountLabel.text = "$" + self.cheque.amount
        let name = self.isContactExists(address: self.cheque.address) ?? "Unknown contact"
        self.contactName.text = name
        self.contactAddress.text = self.cheque.address.address
        let blockies = Blockies(seed: cheque.address.address, size: 5, scale: 4, color: Colors.mainGreen, bgColor: Colors.mostLightGray, spotColor: Colors.mainBlue)
        let img = blockies.createImage()
        self.contactImage.layer.cornerRadius = Constants.TableContact.cornerRadius
        self.contactImage.clipsToBounds = true
        self.contactImage.image = img
        self.contactAddress.font = UIFont(name: Constants.TableContact.font,
                                          size: name != nil ?
                                            Constants.TableContact.minimumFontSize :
                                            Constants.TableContact.maximumFontSize)
        //self.contactAddress.adjustsFontSizeToFitWidth = true
        self.contactAddress.fitTextToBounds()
    }
    
    func mainSetup() {
        self.navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        self.contentView.backgroundColor = Constants.ModalView.ContentView.backgroundColor
        self.contentView.alpha = 1
        self.contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
        self.contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
        self.contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(self.dismissView))
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
        
        processAnimation.setGifImage(UIImage(gifName: "loading.gif"))
        processAnimation.loopCount = -1
        processAnimation.contentMode = .center
        processAnimation.isUserInteractionEnabled = false
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismissView()
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
    
    func showStart(animated: Bool) {
        self.screenStatus = .start
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
        self.screenStatus = .accepting
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
        self.screenStatus = .accepted
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
        self.screenStatus = .save
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
    
    func saveContact() {
        guard let name = contactNameField.text else {
            return
        }
        let contact = Contact(address: cheque.address.address, name: name)
        do {
            try contact.saveContact()
            self.dismissView()
        } catch let error {
            alerts.showErrorAlert(for: self, error: error) {
                self.dismissView()
            }
        }
    }
}

extension AcceptChequeFormController: UITextFieldDelegate {
    
}
