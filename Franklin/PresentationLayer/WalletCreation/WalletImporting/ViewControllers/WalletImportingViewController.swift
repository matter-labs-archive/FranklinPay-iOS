//
//  WalletImportingViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 10/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit
import QRCodeReader
import Web3swift
import EthereumAddress

class WalletImportingViewController: BasicViewController {
    
    @IBOutlet weak var importTypeControl: SegmentedControl!
    @IBOutlet weak var textView: BasicTextView!
    @IBOutlet weak var inputType: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var importButton: BasicGreenButton!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var tapToQR: UILabel!
    @IBOutlet weak var qr: UIButton!
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var settingUp: UILabel!
    
    var activeView: UITextView?
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    let walletsService = WalletsService()
    let appController = AppController()
    let userDefaults = UserDefaultKeys()
    let alerts = Alerts()
    var walletCreated = false
    weak var animationTimer: Timer?
    weak var delegate: ModalViewDelegate?

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainSetup()
        self.setImportView()
        // Do any additional setup after loading the view.
    }
    
    func mainSetup() {
        self.navigationController?.navigationBar.isHidden = false
        
        animationImageView.setGifImage(UIImage(gifName: "loading.gif"))
        animationImageView.loopCount = -1
        animationImageView.frame = CGRect(x: 0, y: 0, width: 0.8*UIScreen.main.bounds.width, height: 257)
        animationImageView.contentMode = .center
        animationImageView.alpha = 0
        animationImageView.isUserInteractionEnabled = false
        
        self.view.backgroundColor = Colors.background
        self.scrollView.backgroundColor = Colors.background
        self.contentView.backgroundColor = Colors.background
        self.inputType.textColor = Colors.textDarkGray
        self.tapToQR.textColor = Colors.textDarkGray
        self.qr.setImage(UIImage(named: "photo"), for: .normal)
        self.textView.delegate = self
        
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

    @IBAction func qrScanTapped(_ sender: Any) {
        readerVC.delegate = self
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
        }
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    @IBAction func changeImportType(_ sender: UISegmentedControl) {
        self.setImportView()
    }
    
    func setImportView() {
        switch self.importTypeControl.selectedSegmentIndex {
        case ImportType.passphrase.rawValue:
            self.setPassphraseView()
        default:
            self.setPrivateKeyView()
        }
    }
    
    func setPassphraseView() {
        self.inputType.text = "PASSPHRASE"
        self.importButton.setTitle("IMPORT", for: .normal)
    }
    
    func setPrivateKeyView() {
        self.inputType.text = "PRIVATE KEY"
        self.importButton.setTitle("IMPORT", for: .normal)
    }
    
    func animation() {
        self.animationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
        self.animateIndicator()
    }
    
    @objc func fireTimer() {
        animationTimer?.invalidate()
        if walletCreated {
            self.goToApp()
        }
    }
    
    func cancelAnimation() {
        animationTimer?.invalidate()
        self.importButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: Constants.Main.animationDuration) {
            self.importButton.alpha = 1
            self.animationImageView.alpha = 0
            self.settingUp.alpha = 0
        }
    }
    
    func animateIndicator() {
        UIView.animate(withDuration: Constants.Main.animationDuration) {
            self.importButton.alpha = 0
            self.animationImageView.alpha = 1
            self.settingUp.alpha = 1
        }
    }
    
    // TODO: - need to make it better
    func creatingWallet(from text: String) {
        DispatchQueue.global().async { [unowned self] in
            do {
                
                let name = Constants.Wallet.newName
                let password = Constants.Wallet.newPassword
                let wallet: Wallet
                switch self.importTypeControl.selectedSegmentIndex {
                case ImportType.passphrase.rawValue:
                    wallet = try self.walletsService.createHDWallet(name: name,
                                                                    password: password,
                                                                    mnemonics: text,
                                                                    backupNeeded: false)
                    
                    let passphraseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassphrase,
                                                              account: wallet.address,
                                                              accessGroup: KeychainConfiguration.accessGroup)
                    try passphraseItem.savePassword(text)
                default:
                    wallet = try self.walletsService.importWalletWithPrivateKey(name: name,
                                                                                key: text,
                                                                                password: password)
                }
                try wallet.save()
                try wallet.addPassword(password)
                CurrentWallet.currentWallet = wallet
                let etherAdded = self.userDefaults.isEtherAdded(for: wallet)
                let franklinAdded = self.userDefaults.isFranklinAdded(for: wallet)
                let daiAdded = self.userDefaults.isDaiAdded(for: wallet)
                let xdaiAdded = self.userDefaults.isXDaiAdded(for: wallet)
                let buffAdded = self.userDefaults.isBuffAdded(for: wallet)
                if !xdaiAdded {
                    do {
                        try self.appController.addXDai(for: wallet)
                    } catch let error {
                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
                    }
                }
                if !franklinAdded {
                    do {
                        try self.appController.addFranklin(for: wallet)
                    } catch let error {
                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
                    }
                }
                if !etherAdded {
                    do {
                        try self.appController.addEther(for: wallet)
                    } catch let error {
                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
                    }
                }
                if !daiAdded {
                    do {
                        try self.appController.addDai(for: wallet)
                    } catch let error {
                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
                    }
                }
                if !buffAdded {
                    do {
                        try self.appController.addBuff(for: wallet)
                    } catch let error {
                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
                    }
                }
                self.finishSavingWallet(with: nil, needDeleteWallet: nil)
            } catch let error {
                self.finishSavingWallet(with: error, needDeleteWallet: nil)
            }
        }
    }
    
    @IBAction func importWallet(_ sender: UIButton) {
        guard let text = self.textView.text else {
            self.alerts.showErrorAlert(for: self,
                                       error: self.importTypeControl.selectedSegmentIndex == 0
                                        ? "Please, enter your passphrase"
                                        : "Please, enter your private key",
                                       completion: nil)
            return
        }
        self.importButton.isUserInteractionEnabled = false
        self.animation()
        self.creatingWallet(from: text)
    }
    
    func finishSavingWallet(with error: Error?, needDeleteWallet: Wallet?) {
        if let wallet = needDeleteWallet {
            do {
                try wallet.delete()
            } catch let deleteErr {
                alerts.showErrorAlert(for: self, error: deleteErr) { [unowned self] in
                    self.cancelAnimation()
                }
            }
        }
        if let err = error {
            alerts.showErrorAlert(for: self, error: err) { [unowned self] in
                self.cancelAnimation()
            }
        } else {
            self.walletCreated = true
            if animationTimer == nil {
                self.goToApp()
            }
        }
    }
    
    func goToApp() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.Main.animationDuration) {
                self.view.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    let tabViewController = self.appController.goToApp()
                    tabViewController.view.backgroundColor = Colors.background
                    let transition = CATransition()
                    transition.duration = Constants.Main.animationDuration
                    transition.type = CATransitionType.push
                    transition.subtype = CATransitionSubtype.fromRight
                    transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                    self.view.window!.layer.add(transition, forKey: kCATransition)
                    self.present(tabViewController, animated: false, completion: nil)
                })
            }
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismissView()
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
        delegate?.modalViewBeenDismissed(updateNeeded: false)
    }
}

extension WalletImportingViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeView = textView
        lastOffset = self.scrollView.contentOffset
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        activeView?.resignFirstResponder()
        activeView = nil
    }
}

extension WalletImportingViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        if keyboardHeight != nil {
            return
        }
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: Constants.Main.animationDuration, animations: {
                self.contentHeight.constant += self.keyboardHeight
            })
            
            // move if keyboard hide input field
            print((scrollView.frame.size.height))
            print((activeView?.frame.origin.y))
            print((activeView?.frame.size.height))
            let distanceToBottom = self.scrollView.frame.size.height - (activeView?.frame.origin.y ?? 0) - (activeView?.frame.size.height ?? 0)
            let collapseSpace = keyboardHeight - distanceToBottom
            
            if collapseSpace < 0 {
                // no collapse
                return
            }
            
            // set new offset for scroll view
            UIView.animate(withDuration: Constants.Main.animationDuration, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: Constants.Main.animationDuration) {
            self.contentHeight.constant -= self.keyboardHeight
            self.scrollView.contentOffset = self.lastOffset
        }
        keyboardHeight = nil
    }
}

extension WalletImportingViewController: QRCodeReaderViewControllerDelegate {
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        textView.text = result.value
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
}
