////
////  AcceptChequeController.swift
////  Franklin
////
////  Created by Anton Grigorev on 28/01/2019.
////  Copyright © 2019 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//class DeeplinkPayViewController: BasicViewController, ModalViewDelegate {
//    
//    let appController = AppController()
//    
//    @IBOutlet weak var logoImage: UIImageView!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var creditBtn: BasicBlueButton!
//    @IBOutlet weak var debitBtn: BasicGreenButton!
//    
//    let cheque: BuffiCode
//    
//    let walletsService = WalletsService()
//    let userDefaults = UserDefaultKeys()
//    let alerts = Alerts()
//    
//    let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
//    
//    init(cheque: BuffiCode) {
//        self.cheque = cheque
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.parent?.view.backgroundColor = .white
//        self.view.alpha = 1
//        self.navigationController?.navigationBar.isHidden = true
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        UIView.animate(withDuration: 1) {
//            self.view.alpha = 1
//        }
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.topViewForModalAnimation.blurView()
//        self.topViewForModalAnimation.alpha = 0
//        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
//        self.topViewForModalAnimation.isUserInteractionEnabled = false
//        self.view.addSubview(topViewForModalAnimation)
//        
//       // self.titleLabel.alpha = 0
//    }
//    
//    func creatingWallet() {
//        DispatchQueue.global().async { [unowned self] in
//            do {
//                let mnemonicFrase = try self.walletsService.generateMnemonics(bitsOfEntropy: 128)
//                let name = Constants.Wallet.newName
//                let password = Constants.Wallet.newPassword
//                let wallet = try self.walletsService.createHDWallet(name: name,
//                                                                    password: password,
//                                                                    mnemonics: mnemonicFrase,
//                                                                    backupNeeded: true)
//                try wallet.save()
//                try wallet.addPassword(password)
//                CurrentWallet.currentWallet = wallet
//                let etherAdded = self.userDefaults.isEtherAdded(for: wallet)
//                let franklinAdded = self.userDefaults.isFranklinAdded(for: wallet)
//                let daiAdded = self.userDefaults.isDaiAdded(for: wallet)
//                let xdaiAdded = self.userDefaults.isXDaiAdded(for: wallet)
//                let buffAdded = self.userDefaults.isBuffAdded(for: wallet)
//                if !xdaiAdded {
//                    do {
//                        try self.appController.addXDai(for: wallet)
//                    } catch let error {
//                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
//                    }
//                }
//                if !franklinAdded {
//                    do {
//                        try self.appController.addFranklin(for: wallet)
//                    } catch let error {
//                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
//                    }
//                }
//                if !etherAdded {
//                    do {
//                        try self.appController.addEther(for: wallet)
//                    } catch let error {
//                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
//                    }
//                }
//                if !daiAdded {
//                    do {
//                        try self.appController.addDai(for: wallet)
//                    } catch let error {
//                        self.finishSavingWallet(with: error, needDeleteWallet: wallet)
//                    }
//                }
//                if !buffAdded {
//                    do {
//                        try self.appController.addBuff(for: wallet)
//                    } catch let error {
//                        fatalError("Can't add ether token - \(String(describing: error))")
//                    }
//                }
//                
//                let passphraseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassphrase,
//                                                          account: wallet.address,
//                                                          accessGroup: KeychainConfiguration.accessGroup)
//                try passphraseItem.savePassword(mnemonicFrase)
//                
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
//                //TODO: - need to do something
//                alerts.showErrorAlert(for: self, error: deleteErr, completion: nil)
//            }
//        }
//        if let err = error {
//            //TODO: - need to do something
//            alerts.showErrorAlert(for: self, error: err, completion: nil)
//        }
//    }
//    
//    func modalViewBeenDismissed(updateNeeded: Bool) {
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
//                self.topViewForModalAnimation.alpha = 0
//                self.titleLabel.alpha = 0
//                self.goToApp()
//            })
//        }
//    }
//    
//    func goToApp() {
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.Main.animationDuration) {
//                self.view.alpha = 0
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                    let tabViewController = self.appController.goToApp()
//                    tabViewController.view.backgroundColor = Colors.background
//                    let transition = CATransition()
//                    transition.duration = Constants.Main.animationDuration
//                    transition.type = CATransitionType.push
//                    transition.subtype = CATransitionSubtype.fromRight
//                    transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
//                    self.view.window!.layer.add(transition, forKey: kCATransition)
//                    self.present(tabViewController, animated: false, completion: nil)
//                })
//            }
//        }
//    }
//    
//    @IBAction func payNormally(_ sender: BasicGreenButton) {
//            self.modalViewAppeared()
//            let vc = PayForCheque(cheque: cheque, credit: false)
//            vc.delegate = self
//            vc.modalPresentationStyle = .overCurrentContext
//            vc.view.layer.speed = Constants.ModalView.animationSpeed
//            self.present(vc, animated: true, completion: nil)
//    }
//    
//    @IBAction func payWithCredit(_ sender: BasicBlueButton) {
//        self.modalViewAppeared()
//        let vc = PayForCheque(cheque: cheque, credit: true)
//        vc.delegate = self
//        vc.modalPresentationStyle = .overCurrentContext
//        vc.view.layer.speed = Constants.ModalView.animationSpeed
//        self.present(vc, animated: true, completion: nil)
//    }
//    
//    func modalViewAppeared() {
//        if let wallets = try? walletsService.getAllWallets(), wallets.isEmpty {
//            self.creatingWallet()
//        }
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
//                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
//                self.titleLabel.alpha = 1.0
//            })
//        }
//    }
//
//}
