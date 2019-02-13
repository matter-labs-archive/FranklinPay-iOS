////
////  WalletCreationAnimationViewController.swift
////  MatterWallet
////
////  Created by Anton Grigorev on 22/01/2019.
////  Copyright © 2019 Matter Inc. All rights reserved.
////
//
//import UIKit
//import NVActivityIndicatorView
//
//class WalletCreationAnimationViewController: UIViewController {
//    
//    @IBOutlet weak var indicator: NVActivityIndicatorView!
//    @IBOutlet weak var processLabel: UILabel!
//    
//    weak var animationTimer: Timer?
//    
//    let walletsService = WalletsService()
//    let appController = AppController()
//    let userDefaults = UserDefaultKeys()
//    let alerts = Alerts()
//    
//    var walletCreated = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        additionalSetup()
//        navigationSetup()
//    }
//    
//    func navigationSetup() {
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//    }
//    
//    func additionalSetup() {
//        self.parent?.view.backgroundColor = .white
//        self.view.alpha = 0
//        self.indicator.color = Colors.positive
//        self.indicator.type = .ballSpinFadeLoader
//    }
//    
//    func animation() {
//        UIView.animate(withDuration: Constants.animationDuration) {
//            self.view.alpha = 1
//        }
//        self.animationTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
//        self.indicator.startAnimating()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.animation()
//        self.creatingWallet()
//    }
//
//    @objc func fireTimer() {
//        print("Timer fired!")
//        animationTimer?.invalidate()
//        if walletCreated {
//            self.goToApp()
//        }
//    }
//    
//    func goToApp() {
//        DispatchQueue.main.async { [unowned self] in
//            UIView.animate(withDuration: Constants.animationDuration) {
//                self.indicator.stopAnimating()
//                self.view.alpha = 0
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                    let tabViewController = self.appController.goToApp()
//                    tabViewController.view.backgroundColor = Colors.background
//                    let transition = CATransition()
//                    transition.duration = Constants.modalViewSpeed
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
//        } else {
//            self.walletCreated = true
//            if animationTimer == nil {
//                self.goToApp()
//            }
//        }
//    }
//    
//    func creatingWallet() {
//        do {
//            let mnemonicFrase = try walletsService.generateMnemonics(bitsOfEntropy: 128)
//            let name = Constants.newWalletName
//            let password = Constants.newWalletPassword
//            let wallet = try self.walletsService.createHDWallet(name: name,
//                                                                password: password,
//                                                                mnemonics: mnemonicFrase)
//            try wallet.save()
//            try wallet.addPassword(password)
//            CurrentWallet.currentWallet = wallet
//            let etherAdded = self.userDefaults.isEtherAdded(for: wallet)
//            let franklinAdded = self.userDefaults.isFranklinAdded(for: wallet)
//            if !franklinAdded {
//                do {
//                    try self.appController.addFranklin(for: wallet)
//                } catch let error {
//                    self.finishSavingWallet(with: error, needDeleteWallet: wallet)
//                }
//            }
////            if !etherAdded {
////                do {
////                    try self.appController.addEther(for: wallet)
////                } catch let error {
////                    self.finishSavingWallet(with: error, needDeleteWallet: wallet)
////                }
////            }
//            self.finishSavingWallet(with: nil, needDeleteWallet: nil)
//        } catch let error {
//            self.finishSavingWallet(with: error, needDeleteWallet: nil)
//        }
//    }
//
//}
