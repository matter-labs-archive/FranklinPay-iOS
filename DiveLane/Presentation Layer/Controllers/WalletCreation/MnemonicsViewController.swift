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

    let keysService: IKeysService
    let localStorage: ILocalDatabase = LocalDatabase()
    var mnemonics: String
    var name: String
    var password: String

    let animation = AnimationController()

    init(name: String, password: String) {
        self.keysService = KeysService()
        self.mnemonics = keysService.generateMnemonics(bitsOfEntropy: 128)
        self.name = name
        self.password = password
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

    func goToApp() {
        let tabViewController = AppController().goToApp()
        tabViewController.view.backgroundColor = UIColor.white
        self.present(tabViewController, animated: true, completion: nil)
    }

    @IBAction func createWalletButtonTapped(_ sender: Any) {
        animation.waitAnimation(isEnabled: true,
                                      notificationText: "Saving wallet",
                                      on: self.view)
        keysService.createNewHDWallet(withName: name, password: password, mnemonics: mnemonics) { (keyWalletModel, error) in
            if let error = error {
                showErrorAlert(for: self, error: error, completion: {
                    self.goToApp()
                })
            } else {
                self.localStorage.saveWallet(wallet: keyWalletModel, completion: { (error) in
                    DispatchQueue.main.async { [weak self] in
                        self?.animation.waitAnimation(isEnabled: false,
                                                      on: (self?.view)!)
                    }
                    if let error = error {
                        showErrorAlert(for: self, error: error, completion: {
                            self.goToApp()
                        })
                    } else {
                        DispatchQueue.global().async {
                            if !UserDefaultKeys().isEtherAdded {
                                AppController().addFirstToken(for: keyWalletModel!, completion: { (error) in
                                    if error == nil {
                                        UserDefaultKeys().setEtherAdded()
                                        UserDefaults.standard.synchronize()
                                        self.goToApp()
                                    } else {
                                        fatalError("Can't add ether - \(String(describing: error))")
                                    }
                                })
                            } else {
                                self.goToApp()
                            }
                        }
                    }
                })
            }
        }
    }
}
