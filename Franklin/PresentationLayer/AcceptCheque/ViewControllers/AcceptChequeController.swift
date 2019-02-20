//
//  AcceptChequeController.swift
//  Franklin
//
//  Created by Anton Grigorev on 28/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class AcceptChequeController: BasicViewController, ModalViewDelegate {
    
    let appController = AppController()
    
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    let cheque: PlasmaCode
    
    let walletsService = WalletsService()
    let userDefaults = UserDefaultKeys()
    let alerts = Alerts()
    
    let topViewForModalAnimation = UIView(frame: UIScreen.main.bounds)
    
    init(cheque: PlasmaCode) {
        self.cheque = cheque
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.topViewForModalAnimation.blurView()
        self.topViewForModalAnimation.alpha = 0
        self.topViewForModalAnimation.tag = Constants.ModalView.ShadowView.tag
        self.topViewForModalAnimation.isUserInteractionEnabled = false
        self.view.addSubview(topViewForModalAnimation)
        
        self.titleLabel.alpha = 0
    }
    
    func creatingWallet() {
        DispatchQueue.global().async { [unowned self] in
            do {
                let mnemonicFrase = try self.walletsService.generateMnemonics(bitsOfEntropy: 128)
                let name = Constants.Wallet.newName
                let password = Constants.Wallet.newPassword
                let wallet = try self.walletsService.createHDWallet(name: name,
                                                                    password: password,
                                                                    mnemonics: mnemonicFrase,
                                                                    backupNeeded: true)
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
                
                let passphraseItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassphrase,
                                                          account: wallet.address,
                                                          accessGroup: KeychainConfiguration.accessGroup)
                try passphraseItem.savePassword(mnemonicFrase)
                
                self.finishSavingWallet(with: nil, needDeleteWallet: nil)
            } catch let error {
                self.finishSavingWallet(with: error, needDeleteWallet: nil)
            }
        }
    }
    
    func finishSavingWallet(with error: Error?, needDeleteWallet: Wallet?) {
        if let wallet = needDeleteWallet {
            do {
                try wallet.delete()
            } catch let deleteErr {
                //TODO: - need to do something
                alerts.showErrorAlert(for: self, error: deleteErr, completion: nil)
            }
        }
        if let err = error {
            //TODO: - need to do something
            alerts.showErrorAlert(for: self, error: err, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.modalViewAppeared()
        let acceptChequeForm = AcceptChequeFormController(cheque: cheque)
        acceptChequeForm.delegate = self
        acceptChequeForm.modalPresentationStyle = .overCurrentContext
        acceptChequeForm.view.layer.speed = Constants.ModalView.animationSpeed
        self.present(acceptChequeForm, animated: true, completion: nil)
    }
    
    func modalViewBeenDismissed(updateNeeded: Bool) {
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = 0
                self.titleLabel.alpha = 0
                self.goToApp()
            })
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
    
    func modalViewAppeared() {
        if let wallets = try? walletsService.getAllWallets(), wallets.isEmpty {
            self.creatingWallet()
        }
        DispatchQueue.main.async { [unowned self] in
            UIView.animate(withDuration: Constants.ModalView.animationDuration, animations: {
                self.topViewForModalAnimation.alpha = Constants.ModalView.ShadowView.alpha
                self.titleLabel.alpha = 1.0
            })
        }
    }

}
