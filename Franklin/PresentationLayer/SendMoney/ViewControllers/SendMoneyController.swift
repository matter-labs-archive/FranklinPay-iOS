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

protocol ModalViewDelegate : class {
    func modalViewBeenDismissed()
    func modalViewAppeared()
}

class SendMoneyController: BasicViewController {
    
    enum TextFieldsTags: Int {
        case amount = 1
        case search = 2
    }
    
    enum SendingScreenStatus {
        case start
        case searching
        case confirm
        case sending
        case ready
    }
    
    @IBOutlet weak var amountTextField: BasicTextField!
    @IBOutlet weak var searchTextField: BasicTextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var sendToContactLabel: UILabel!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var mainButton: BasicWhiteButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchStackView: UIStackView!
    @IBOutlet weak var amountStackView: UIStackView!
    @IBOutlet weak var contactStack: UIStackView!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactAddress: UILabel!
    @IBOutlet weak var sendingGif: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readyIcon: UIImageView!
    
    var searchStackOrigin: CGFloat = 0
    weak var delegate: ModalViewDelegate?
    var contactsList: [Contact] = []
    let contactsService = ContactsService()
    var chosenContact: Contact?
    var screenStatus: SendingScreenStatus = .start
    
    private let reuseIdentifier = "ContactCell"
    private let sectionInsets = UIEdgeInsets(top: 0,
                                             left: 0,
                                             bottom: 0,
                                             right: 0)
    private let itemsPerRow: CGFloat = 3
    
    weak var animationTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.mainSetup()
        self.setupTextFields()
        self.setupTableView()
        //self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchStackOrigin = searchStackView.frame.origin.y
        showStart(animated: false)
        getAllContacts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chosenContact = nil
    }
    
    func setupTextFields() {
        searchTextField.delegate = self
        amountTextField.delegate = self
        
        amountTextField.tag = TextFieldsTags.amount.rawValue
        searchTextField.tag = TextFieldsTags.search.rawValue
    }
    
    func getAllContacts() {
        do {
            let contacts = try contactsService.getAllContacts()
            updateContactsList(with: contacts)
        } catch {
            updateContactsList(with: [])
        }
    }
    
    func setupTableView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let footerView = UIView()
        footerView.backgroundColor = Colors.background
        
        let nibSearch = UINib.init(nibName: "ContactCell", bundle: nil)
        self.collectionView.register(nibSearch, forCellWithReuseIdentifier: reuseIdentifier)
        self.contactsList.removeAll()
    }
    
    func mainSetup() {
        self.navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        self.contentView.backgroundColor = Colors.background
        self.contentView.alpha = 1
        self.contentView.layer.cornerRadius = Constants.ModalView.ContentView.cornerRadius
        self.contentView.layer.borderColor = Constants.ModalView.ContentView.borderColor
        self.contentView.layer.borderWidth = Constants.ModalView.ContentView.borderWidth
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(self.dismissView))
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
        
        let tapOnChosenContact: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showSearch(animated:)))
        tapOnChosenContact.cancelsTouchesInView = false
        contactStack.addGestureRecognizer(tapOnChosenContact)
        
        sendingGif.setGifImage(UIImage(gifName: "loading.gif"))
        sendingGif.loopCount = -1
        sendingGif.contentMode = .center
        sendingGif.isUserInteractionEnabled = false
    }
    
    func showStart(animated: Bool) {
        self.screenStatus = .start
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
            self.titleLabel.text = "Send money"
            self.sendingGif.alpha = 0
            self.shareLabel.alpha = 1
            self.collectionView.alpha = 0
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.isHidden = true
            self.mainButton.setTitle("Other app...", for: .normal)
            self.mainButton.changeColorOn(background: Colors.textWhite, text: Colors.mainBlue)
            self.mainButton.setImage(UIImage(named: "share-blue"), for: .normal)
//            self.mainButton.setTitleColor(Colors.mainBlue, for: .normal)
//            self.mainButton.backgroundColor = .white
            self.mainButton.layer.borderWidth = 1
            self.searchStackView.frame.origin.y = self.searchStackOrigin
            self.searchTextField.alpha = 1
            self.searchTextField.isUserInteractionEnabled = true
            self.amountLabel.alpha = 1
            self.contactStack.alpha = 0
            self.contactStack.isUserInteractionEnabled = false
            self.separatorView.alpha = 1
            self.sendToContactLabel.alpha = 1
            self.readyIcon.alpha = 0
        }
    }
    
    @objc func showSearch(animated: Bool) {
        self.screenStatus = .searching
        self.chosenContact = nil
        UIView.animate(withDuration: Constants.ModalView.animationDuration) { [unowned self] in
            self.titleLabel.text = "Send money"
            self.sendingGif.alpha = 0
            self.shareLabel.alpha = 0
            self.collectionView.alpha = 1
            self.collectionView.isUserInteractionEnabled = true
            self.collectionView.isHidden = false
            self.mainButton.setTitle("Back", for: .normal)
            self.mainButton.changeColorOn(background: Colors.textWhite, text: Colors.mainBlue)
            self.mainButton.setImage(UIImage(named: "left-blue"), for: .normal)
//            self.mainButton.setTitleColor(Colors.mainBlue, for: .normal)
//            self.mainButton.backgroundColor = .white
            self.mainButton.layer.borderWidth = 1
            self.searchTextField.alpha = 1
            self.searchTextField.isUserInteractionEnabled = true
            self.contactStack.alpha = 0
            self.contactStack.isUserInteractionEnabled = false
            self.separatorView.alpha = 0
            self.sendToContactLabel.alpha = 1
        }
        UIView.animate(withDuration: Constants.ModalView.animationDuration) { [unowned self] in
            self.searchStackView.frame.origin.y = self.amountStackView.frame.origin.y
        }
    }
    
    func showConfirmScreen(animated: Bool, for contact: Contact) {
        self.screenStatus = .confirm
        self.chosenContact = contact
        
        let blockies = Blockies(seed: contact.address,
                                size: 5,
                                scale: 4,
                                color: Colors.mainGreen,
                                bgColor: Colors.mostLightGray,
                                spotColor: Colors.mainBlue)
        let img = blockies.createImage()
        self.contactImage.image = img
        self.contactImage.layer.cornerRadius = Constants.CollectionCell.Image.cornerRadius
        self.contactImage.clipsToBounds = true
        self.contactName.text = contact.name
        self.contactAddress.text = contact.address
        
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
            self.titleLabel.text = "Send money"
            self.sendingGif.alpha = 0
            self.shareLabel.alpha = 0
            self.collectionView.alpha = 0
            self.collectionView.isUserInteractionEnabled = false
            self.collectionView.isHidden = true
            
            self.mainButton.setTitle("Send to \(contact.name)", for: .normal)
            self.mainButton.setImage(UIImage(named: "send-white"), for: .normal)
//            self.mainButton.setTitleColor(.white, for: .normal)
//            self.mainButton.backgroundColor = Colors.orange
            self.mainButton.layer.borderWidth = 0
            self.mainButton.changeColorOn(background: Colors.orange, text: Colors.textWhite)
            
            self.searchStackView.frame.origin.y = self.searchStackOrigin
            self.searchTextField.alpha = 0
            self.searchTextField.isUserInteractionEnabled = false
            self.contactStack.alpha = 1
            self.contactStack.isUserInteractionEnabled = true
            self.separatorView.alpha = 0
            self.sendToContactLabel.alpha = 0
        }
    }
    
    @objc func showSending(animated: Bool) {
        self.screenStatus = .sending
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0, animations: { [unowned self] in
            self.titleLabel.text = "Sending..."
            self.sendingGif.alpha = 1
            self.sendToContactLabel.alpha = 0
            self.searchTextField.alpha = 0
            self.mainButton.alpha = 0
            self.searchTextField.isUserInteractionEnabled = false
            self.amountTextField.isUserInteractionEnabled = false
            self.contactStack.isUserInteractionEnabled = false
        }) { [unowned self] (completed) in
            if completed {
                self.sending()
            }
        }
    }
    
    func sending() {
        self.animationTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
    
    @objc func fireTimer() {
        animationTimer?.invalidate()
        self.showReady(animated: true)
    }
    
    @objc func showReady(animated: Bool) {
        self.screenStatus = .ready
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
            self.readyIcon.alpha = 1
            self.readyIcon.transform = CGAffineTransform(scaleX: 3, y: 3)
        }
        UIView.animate(withDuration: animated ?
            Constants.ModalView.animationDuration : 0) { [unowned self] in
            self.titleLabel.text = "Sent!"
            self.titleLabel.textColor = Colors.mainGreen
            self.sendingGif.alpha = 0
            self.mainButton.alpha = 1
            self.mainButton.setTitle("Close", for: .normal)
            self.mainButton.setImage(nil, for: .normal)
            //            self.mainButton.backgroundColor = Colors.mainBlue
            
            self.mainButton.changeColorOn(background: Colors.mainBlue, text: Colors.textWhite)
        }
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismissView()
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        switch screenStatus {
        case .start:
            guard let text = self.amountTextField.text else {
                self.amountTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                return
            }
            guard let amount = Float(text) else {
                self.amountTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
                                                                       attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                return
            }
            guard amount > 0 else {
                self.amountTextField.attributedPlaceholder = NSAttributedString(string: "Should be more",
                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                return
            }
            
            let stringToShare = "I have sent you a cheque of \(text)"
            
            let itemsToShare = [ stringToShare ]
            let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.mail, UIActivity.ActivityType.message, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.markupAsPDF ]
            self.present(activityViewController, animated: true, completion: nil)
        case .searching:
            showStart(animated: true)
        case .confirm:
            guard let text = self.amountTextField.text else {
                self.amountTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                return
            }
            guard let amount = Float(text) else {
                self.amountTextField.attributedPlaceholder = NSAttributedString(string: "Please, fill this field",
                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                return
            }
            guard amount > 0 else {
                self.amountTextField.attributedPlaceholder = NSAttributedString(string: "Should be more",
                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
                return
            }
            showSending(animated: true)
        case .ready:
            self.dismissView()
        case .sending:
            self.dismissView()
        }
    }
    
    func emptyContactsList() {
        contactsList = []
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    func updateContactsList(with list: [Contact]) {
        DispatchQueue.main.async { [weak self] in
            self?.contactsList = list
            self?.collectionView?.reloadData()
        }
    }
    
    func searchContact(string: String) {
        guard let list = try? ContactsService().getFullContactsList(for: string) else {
            self.emptyContactsList()
            return
        }
        self.updateContactsList(with: list)
    }
}

extension SendMoneyController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if contactsList.isEmpty {
            return 0
        } else {
            return contactsList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !contactsList.isEmpty {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCell",
                                                                for: indexPath) as? ContactCell else {
                                                                    return UICollectionViewCell()
            }
            cell.configure(with: contactsList[indexPath.row])
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contact = contactsList[indexPath.row]
        self.showConfirmScreen(animated: true, for: contact)
    }
}

extension SendMoneyController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width * Constants.CollectionView.widthCoeff - 15

        return CGSize(width: width, height: Constants.CollectionCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension SendMoneyController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string) as String
        if textField == searchTextField {
            if newText == "" {
                getAllContacts()
            } else {
                let contact = newText
                searchContact(string: contact)
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print(textField.tag)
        if textField == searchTextField {
            showSearch(animated: true)
        }
        return true
    }
}
