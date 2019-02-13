////
////  WalletCreationViewController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 09/01/2019.
////  Copyright © 2019 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//class WalletCreationViewController: BasicViewController {
//
//    @IBOutlet weak var mnemonic: UILabel!
//    @IBOutlet weak var info: UILabel!
//    @IBOutlet weak var attention: UILabel!
//    @IBOutlet weak var copyButton: BasicBlueButton!
//    @IBOutlet weak var nextButton: BasicGreenButton!
//    @IBOutlet weak var bottomView: UIView!
//    @IBOutlet weak var topView: UIView!
//    
//    let walletsService = WalletsService()
//    let appController = AppController()
//    let userDefaults = UserDefaultKeys()
//    let alerts = Alerts()
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
//        mainSetup()
//        setMnemonic()
//    }
//    
//    func mainSetup() {
//        self.mnemonic.text = "---"
//        self.info.text = "Please, copy passphrase and save it. It is the only way to restore your wallet"
//        self.attention.text = "ATTENTION!"
//        self.nextButton.setTitle("PRESS COPY FIRSTLY", for: .normal)
//        self.copyButton.setTitle("COPY TO PASTEBOARD", for: .normal)
//        self.nextButton.isEnabled = false
//        self.attention.textColor = Colors.secondMain
//        self.mnemonic.textColor = Colors.secondMain
//        self.topView.backgroundColor = Colors.negative
//        self.bottomView.backgroundColor = Colors.firstMain
//    }
//    
//    func setMnemonic() {
//        do {
//            let mnemonicFrase = try walletsService.generateMnemonics(bitsOfEntropy: 128)
//            self.mnemonic.text = mnemonicFrase
//        } catch {
//            fatalError("Can't create mnemonic")
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }
//    
//    @IBAction func copyButtonTapped(_ sender: Any) {
//        guard let mnemonic = self.mnemonic.text else {
//            alerts.showErrorAlert(for: self, error: "Can't get mnemonic text", completion: nil)
//            return
//        }
//        self.nextButton.isEnabled = true
//        self.nextButton.setTitle("SAVE WALLET", for: .normal)
//        UIPasteboard.general.string = mnemonic
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
//    
//    @IBAction func createWalletButtonTapped(_ sender: Any) {
//        DispatchQueue.global().async { [unowned self] in
//            do {
//                let name = Constants.newWalletName
//                let password = Constants.newWalletPassword
//                guard let mnemonic = self.mnemonic.text else {
//                    self.alerts.showErrorAlert(for: self, error: "Can't get mnemonic text", completion: nil)
//                    return
//                }
//                let wallet = try self.walletsService.createHDWallet(name: name,
//                                                                    password: password,
//                                                                    mnemonics: mnemonic)
//                try wallet.save()
//                try wallet.addPassword(password)
//                CurrentWallet.currentWallet = wallet
//                let etherAdded = self.userDefaults.isEtherAdded(for: wallet)
//                let franklinAdded = self.userDefaults.isFranklinAdded(for: wallet)
//                if !franklinAdded {
//                    do {
//                        try self.appController.addFranklin(for: wallet)
//                    } catch let error {
//                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
//                    }
//                }
////                if !etherAdded {
////                    do {
////                        try self.appController.addEther(for: wallet)
////                    } catch let error {
////                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
////                    }
////                }
//                self.finishSavingWallet(with: nil, needDeleteWallet: nil)
//            } catch let error {
//                self.finishSavingWallet(with: error, needDeleteWallet: nil)
//            }
//        }
//    }
//}
