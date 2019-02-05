////
////  WalletImportingViewController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 10/01/2019.
////  Copyright © 2019 Matter Inc. All rights reserved.
////
//
//import UIKit
//import QRCodeReader
//import Web3swift
//import EthereumAddress
//
//class WalletImportingViewController: BasicViewController {
//    
//    @IBOutlet weak var importTypeControl: SegmentedControl!
//    @IBOutlet weak var textView: BasicTextView!
//    @IBOutlet weak var inputType: UILabel!
//    @IBOutlet weak var contentView: UIView!
//    @IBOutlet weak var scrollView: UIScrollView!
//    @IBOutlet weak var importButton: BasicGreenButton!
//    @IBOutlet weak var contentHeight: NSLayoutConstraint!
//    @IBOutlet weak var tapToQR: UILabel!
//    @IBOutlet weak var qr: UIButton!
//    
//    var activeView: UITextView?
//    var lastOffset: CGPoint!
//    var keyboardHeight: CGFloat!
//    
//    let walletsService = WalletsService()
//    let appController = AppController()
//    let userDefaults = UserDefaultKeys()
//    let alerts = Alerts()
//
//    lazy var readerVC: QRCodeReaderViewController = {
//        let builder = QRCodeReaderViewControllerBuilder {
//            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
//        }
//        
//        return QRCodeReaderViewController(builder: builder)
//    }()
//    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.mainSetup()
//        self.setImportView()
//        // Do any additional setup after loading the view.
//    }
//    
//    func mainSetup() {
//        self.navigationController?.navigationBar.isHidden = false
//        
//        self.view.backgroundColor = Colors.firstMain
//        self.scrollView.backgroundColor = Colors.firstMain
//        self.contentView.backgroundColor = Colors.firstMain
//        self.inputType.textColor = Colors.secondMain
//        self.tapToQR.textColor = Colors.secondMain
//        self.qr.setImage(UIImage(named: "qr"), for: .normal)
//        self.textView.delegate = self
//        
//         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//        
//        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
//    }
//    
//    @objc func returnTextView(gesture: UIGestureRecognizer) {
//        guard activeView != nil else {
//            return
//        }
//        activeView?.resignFirstResponder()
//        activeView = nil
//    }
//
//    @IBAction func qrScanTapped(_ sender: Any) {
//        readerVC.delegate = self
//        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
//        }
//        readerVC.modalPresentationStyle = .formSheet
//        present(readerVC, animated: true, completion: nil)
//    }
//    
//    @IBAction func changeImportType(_ sender: UISegmentedControl) {
//        self.setImportView()
//    }
//    
//    func setImportView() {
//        switch self.importTypeControl.selectedSegmentIndex {
//        case ImportType.passphrase.rawValue:
//            self.setPassphraseView()
//        default:
//            self.setPrivateKeyView()
//        }
//    }
//    
//    func setPassphraseView() {
//        self.inputType.text = "PASSPHRASE"
//        self.importButton.setTitle("IMPORT", for: .normal)
//    }
//    
//    func setPrivateKeyView() {
//        self.inputType.text = "PRIVATE KEY"
//        self.importButton.setTitle("IMPORT", for: .normal)
//    }
//    
//    @IBAction func importWallet(_ sender: UIButton) {
//        DispatchQueue.global().async { [unowned self] in
//            do {
//                let name = Constants.newWalletName
//                let password = Constants.newWalletPassword
//                guard let text = self.textView.text else {
//                    self.alerts.showErrorAlert(for: self,
//                                               error: self.importTypeControl.selectedSegmentIndex == 0
//                                                ? "Please, enter your passphrase"
//                                                : "Please, enter your private key",
//                                               completion: nil)
//                    return
//                }
//                let wallet: Wallet
//                switch self.importTypeControl.selectedSegmentIndex {
//                case ImportType.passphrase.rawValue:
//                    wallet = try self.walletsService.createHDWallet(name: name,
//                                                                    password: password,
//                                                                    mnemonics: text)
//                default:
//                    wallet = try self.walletsService.importWalletWithPrivateKey(name: name, key: text, password: password)
//                }
//                try wallet.save()
//                try wallet.addPassword(password)
//                CurrentWallet.currentWallet = wallet
//                let etherAdded = self.userDefaults.isEtherAdded(for: wallet)
//                let franklinAdded = self.userDefaults.isFranklinAdded(for: wallet)
////                if !etherAdded {
////                    do {
////                        try self.appController.addEther(for: wallet)
////                    } catch let error {
////                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
////                    }
////                }
//                if !franklinAdded {
//                    do {
//                        try self.appController.addFranklin(for: wallet)
//                    } catch let error {
//                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
//                    }
//                }
//                self.finishSavingWallet(with: nil, needDeleteWallet: nil)
//            } catch let error {
//                self.finishSavingWallet(with: error, needDeleteWallet: nil)
//            }
//        }
//    }
//    
//    func finishSavingWallet(with error: Error?, needDeleteWallet: Wallet?) {
//        if let wallet = needDeleteWallet {
//            do {
//                try wallet.delete()
//            } catch let deleteErr {
//                alerts.showErrorAlert(for: self, error: deleteErr, completion: nil)
//            }
//        }
//        if let err = error {
//            alerts.showErrorAlert(for: self, error: err, completion: nil)
//        } else {
//            DispatchQueue.main.async {
//                let tabViewController = self.appController.goToApp()
//                tabViewController.view.backgroundColor = Colors.firstMain
//                self.present(tabViewController, animated: true, completion: nil)
//            }
//        }
//    }
//}
//
//extension WalletImportingViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        activeView = textView
//        lastOffset = self.scrollView.contentOffset
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        activeView?.resignFirstResponder()
//        activeView = nil
//    }
//}
//
//extension WalletImportingViewController {
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if keyboardHeight != nil {
//            return
//        }
//        
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            keyboardHeight = keyboardSize.height
//            
//            // so increase contentView's height by keyboard height
//            UIView.animate(withDuration: Constants.animationDuration, animations: {
//                self.contentHeight.constant += self.keyboardHeight
//            })
//            
//            // move if keyboard hide input field
//            print((scrollView.frame.size.height))
//            print((activeView?.frame.origin.y))
//            print((activeView?.frame.size.height))
//            let distanceToBottom = self.scrollView.frame.size.height - (activeView?.frame.origin.y)! - (activeView?.frame.size.height)!
//            let collapseSpace = keyboardHeight - distanceToBottom
//            
//            if collapseSpace < 0 {
//                // no collapse
//                return
//            }
//            
//            // set new offset for scroll view
//            UIView.animate(withDuration: Constants.animationDuration, animations: {
//                // scroll to the position above keyboard 10 points
//                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
//            })
//        }
//    }
//    
//    @objc func keyboardWillHide(notification: NSNotification) {
//        UIView.animate(withDuration: Constants.animationDuration) {
//            self.contentHeight.constant -= self.keyboardHeight
//            
//            self.scrollView.contentOffset = self.lastOffset
//        }
//        
//        keyboardHeight = nil
//    }
//}
//
//extension WalletImportingViewController: QRCodeReaderViewControllerDelegate {
//    
//    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
//        reader.stopScanning()
//        textView.text = result.value
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func readerDidCancel(_ reader: QRCodeReaderViewController) {
//        reader.stopScanning()
//        dismiss(animated: true, completion: nil)
//    }
//    
//}
