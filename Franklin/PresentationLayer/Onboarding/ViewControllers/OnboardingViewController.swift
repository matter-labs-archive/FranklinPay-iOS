//
//  OnboardingViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import SwiftyGif

class OnboardingViewController: BasicViewController {
    weak var animationTimer: Timer?
    let walletsService = WalletsService()
    let appController = AppController()
    let userDefaults = UserDefaultKeys()
    let alerts = Alerts()
    var walletCreated = false

    var pageViewController: UIPageViewController!
    
    @IBOutlet weak var settingUp: UILabel!
    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var link: UILabel!
    @IBOutlet weak var bottomInfo: UILabel!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var continueButton: BasicGreenButton!
    @IBOutlet weak var animationImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.parent?.view.backgroundColor = .white
        self.view.alpha = 0
        self.navigationController?.navigationBar.isHidden = true
        createView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1) {
            self.view.alpha = 1
        }
    }
    
    func createView() {
        animationImageView.setGifImage(UIImage(gifName: "loading.gif"))
        animationImageView.loopCount = -1
        
        prodName.text = "FRANKLIN"
        prodName.textAlignment = .center
        prodName.textColor = Colors.textDarkGray
        prodName.font = UIFont(name: Constants.Fonts.franklinSemibold, size: 55) ?? UIFont.boldSystemFont(ofSize: 55)
        
        subtitle.textAlignment = .center
        subtitle.text = "SECURE DOLLAR WALLET"
        subtitle.textColor = Colors.textDarkGray
        subtitle.font = UIFont(name: Constants.Fonts.franklinMedium, size: 22) ?? UIFont.systemFont(ofSize: 22)
        
        bottomInfo.textAlignment = .center
        bottomInfo.text = "By clicking 'Continue' you agree to the"
        bottomInfo.textColor = Colors.textDarkGray
        bottomInfo.font = UIFont(name: Constants.Fonts.regular, size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        let attrs = [
            NSAttributedString.Key.font : UIFont(name: Constants.Fonts.regular, size: 16) ?? UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : Colors.mainGreen,
            NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]
        let buttonTitleString = NSAttributedString(string: "terms and conditions", attributes: attrs)
        link.attributedText = buttonTitleString
        
        settingUp.textAlignment = .center
        settingUp.text = "Setting up your wallet"
        settingUp.textColor = Colors.textDarkGray
        settingUp.font = UIFont(name: Constants.Fonts.regular, size: 24) ?? UIFont.systemFont(ofSize: 24)
        
        animationImageView.frame = CGRect(x: 0, y: 0, width: 0.8*UIScreen.main.bounds.width, height: 257)
        animationImageView.contentMode = .center
        animationImageView.alpha = 0
        animationImageView.isUserInteractionEnabled = false
        
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "franklin")!
        
        settingUp.alpha = 0
        
        continueButton.addTarget(self,
                                      action: #selector(continueAction(sender:)),
                                      for: .touchUpInside)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.alpha = 1
        
//        link.addTarget(self, action: #selector(readTerms(sender:)), for: .touchUpInside)
        
    }
    
    // TODO: - need to make it better
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
        } else {
            self.walletCreated = true
            if animationTimer == nil {
                self.goToApp()
            }
        }
    }
    
    @objc func continueAction(sender: UIButton) {
        self.continueButton.isUserInteractionEnabled = false
        self.animation()
        self.creatingWallet()
    }
    
    @objc func readTerms(sender: UIButton) {
        //TODO: - need to read terms
        print("Need to open terms")
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
    
    func animateIndicator() {
        UIView.animate(withDuration: Constants.Main.animationDuration) {
            self.continueButton.alpha = 0
            self.link.alpha = 0
            self.bottomInfo.alpha = 0
            self.animationImageView.alpha = 1
            self.settingUp.alpha = 1
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

}
