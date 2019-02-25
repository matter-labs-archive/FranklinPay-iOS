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
    
    // MARK: - Outlets
    
    @IBOutlet weak var importTypeControl: SegmentedControl!
    @IBOutlet weak var textView: BasicTextView!
    @IBOutlet weak var inputType: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var importButton: BasicGreenButton!
    @IBOutlet weak var tapToQR: UILabel!
    @IBOutlet weak var qr: UIButton!
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var settingUp: UILabel!
    
    // MARK: - Internal vars
    
    internal var activeView: UITextView?

    internal let navigationItems = NavigationItems()
    internal let appController = AppController()
    internal let walletCreating = WalletCreating()
    internal let userDefaults = UserDefaultKeys()
    internal let alerts = Alerts()
    
    internal var walletCreated = false
    
    // MARK: - Weak vars
    
    weak var animationTimer: Timer?
    weak var delegate: ModalViewDelegate?
    
    // MARK: - Lazy vars

    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    // MARK: - Lifesycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainSetup()
        setImportView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigation(hidden: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNavigation(hidden: true)
    }
    
    // MARK: - Main setup
    
    func mainSetup() {
        
        animationImageView.setGifImage(UIImage(gifName: "loading.gif"))
        animationImageView.loopCount = -1
        animationImageView.frame = CGRect(x: 0, y: 0, width: 0.8*UIScreen.main.bounds.width, height: 257)
        animationImageView.contentMode = .center
        animationImageView.alpha = 0
        animationImageView.isUserInteractionEnabled = false
        
        view.backgroundColor = Colors.background
        contentView.backgroundColor = Colors.background
        inputType.textColor = Colors.textDarkGray
        tapToQR.textColor = Colors.textDarkGray
        qr.setImage(UIImage(named: "photo"), for: .normal)
        textView.delegate = self
        
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    func setNavigation(hidden: Bool) {
        navigationController?.setNavigationBarHidden(hidden, animated: true)
        navigationController?.makeClearNavigationController()
        if CurrentWallet.currentWallet != nil {
            let home = navigationItems.homeItem(target: self, action: #selector(goToApp))
            navigationItem.setRightBarButton(home, animated: false)
        }
    }
    
    func setImportView() {
        switch importTypeControl.selectedSegmentIndex {
        case ImportType.passphrase.rawValue:
            setPassphraseView()
        default:
            setPrivateKeyView()
        }
    }
    
    func setPassphraseView() {
        inputType.text = "PASSPHRASE"
        importButton.setTitle("IMPORT", for: .normal)
    }
    
    func setPrivateKeyView() {
        inputType.text = "PRIVATE KEY"
        importButton.setTitle("IMPORT", for: .normal)
    }
    
    // MARK: - Animation
    
    func animation() {
        navigationController?.navigationBar.isHidden = true
        animationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
        animateIndicator()
    }
    
    @objc func fireTimer() {
        animationTimer?.invalidate()
        if walletCreated {
            goToApp()
        }
    }
    
    func cancelAnimation() {
        animationTimer?.invalidate()
        importButton.isUserInteractionEnabled = true
        UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
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
    
    // MARK: - Actions
    
    func creatingWallet(from text: String) {
        DispatchQueue.global().async { [unowned self] in
            do {
                let wallet: Wallet
                switch self.importTypeControl.selectedSegmentIndex {
                case ImportType.passphrase.rawValue:
                    wallet = try self.walletCreating.importWalletWithPassphrase(passphrase: text)
                default:
                    wallet = try self.walletCreating.importWalletWithPrivateKey(key: text)
                }
                self.finishSavingWallet(wallet)
            } catch let error {
                self.alerts.showErrorAlert(for: self, error: "Wrong input") { [unowned self] in
                    self.cancelAnimation()
                }
            }
        }
    }
    
    func deleteWallet(wallet: Wallet, withError error: Error) {
        do {
            try wallet.delete()
            alerts.showErrorAlert(for: self, error: error) { [unowned self] in
                self.cancelAnimation()
            }
        } catch let deleteErr {
            alerts.showErrorAlert(for: self, error: deleteErr) { [unowned self] in
                self.cancelAnimation()
            }
        }
    }
    
    func finishSavingWallet(_ wallet: Wallet) {
        do {
            try walletCreating.prepareWallet(wallet)
            CurrentWallet.currentWallet = wallet
            walletCreated = true
            if animationTimer == nil {
                goToApp()
            }
        } catch let error {
            deleteWallet(wallet: wallet, withError: error)
        }
        
    }
    
    @objc func goToApp() {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.Main.animationDuration) { [unowned self] in
                self.view.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [unowned self] in
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
    
    // MARK: - Button actions
    
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
        setImportView()
    }
    
    @IBAction func importWallet(_ sender: UIButton) {
        guard let text = textView.text else {
            alerts.showErrorAlert(for: self,
                                       error: importTypeControl.selectedSegmentIndex == 0
                                        ? "Please, enter your passphrase"
                                        : "Please, enter your private key",
                                       completion: nil)
            return
        }
        importButton.isUserInteractionEnabled = false
        animation()
        creatingWallet(from: text)
    }
}

extension WalletImportingViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
    }
}
