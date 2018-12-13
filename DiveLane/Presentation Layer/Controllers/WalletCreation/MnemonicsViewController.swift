//
//  MnemonicsViewController.swift
//  DiveLane
//
//  Created by NewUser on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class MnemonicsViewController: UIViewController {
    @IBOutlet weak var mnemonicsLabel: UILabel!

    let walletsService = WalletsService()
    let walletsStorage = WalletsStorage()
    var mnemonics: String
    var name: String
    var password: String

    let animation = AnimationController()

    init(name: String, password: String) {
        self.name = name
        self.password = password
        do {
            let mnemonics = try walletsService.generateMnemonics(bitsOfEntropy: 128)
            self.mnemonics = mnemonics
        } catch {
            self.mnemonics = ""
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mnemonicsLabel.text = mnemonics
    }

    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = mnemonics
    }

    func finishSavingWallet(with error: Error?, needDeleteWallet: WalletModel?) {
        self.animation.waitAnimation(isEnabled: false,
                                     on: self.view)
        if let wallet = needDeleteWallet {
            do {
                try self.walletsStorage.deleteWallet(wallet: wallet)
            } catch let deleteErr {
                Alerts().showErrorAlert(for: self,
                                        error: deleteErr,
                                        completion: {
                                            return
                })
            }
        }
        if let err = error {
            Alerts().showErrorAlert(for: self,
                                    error: err,
                                    completion: {
                                        return
            })
        } else {
            DispatchQueue.main.async {
                let tabViewController = AppController().goToApp()
                tabViewController.view.backgroundColor = UIColor.white
                self.present(tabViewController, animated: true, completion: nil)
            }
        }
    }
    
    func createPassword(_ password: String, forWallet: WalletModel?) {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                                                    account: "\(forWallet?.name ?? "")-password",
                accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }

    @IBAction func createWalletButtonTapped(_ sender: Any) {
        animation.waitAnimation(isEnabled: true,
                                      notificationText: "Saving wallet",
                                      on: self.view)
        DispatchQueue.global().async { [weak self] in
            do {
                guard let name = self?.name else {return}
                guard let password = self?.password else {return}
                guard let mnemonics = self?.mnemonics else {return}
                let hdwallet = try self?.walletsService.createHDWallet(name: name,
                                                                     password: password,
                                                                     mnemonics: mnemonics)
                guard let wallet = hdwallet else {return}
                try self?.walletsStorage.saveWallet(wallet: wallet)
                self?.createPassword(password, forWallet: wallet)
                try self?.walletsStorage.selectWallet(wallet: wallet)
                if !UserDefaultKeys().isEtherAdded {
                    AppController().addFirstToken(for: wallet, completion: { (error) in
                        if error == nil {
                            UserDefaultKeys().setEtherAdded()
                            UserDefaults.standard.synchronize()
                            self?.finishSavingWallet(with: nil, needDeleteWallet: nil)
                        } else {
                            self?.finishSavingWallet(with: error, needDeleteWallet: wallet)
                        }
                    })
                } else {
                    self?.finishSavingWallet(with: nil, needDeleteWallet: nil)
                }
            } catch let error {
                self?.finishSavingWallet(with: error, needDeleteWallet: nil)
            }
        }
        
    }
}
