//
//  CreateWalletPincodeViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 12/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class CreateWalletPincodeViewController: PincodeViewController {

    var pincode: String = ""
    var repeatedPincode: String = ""
    var status: PincodeCreationStatus = .new

    var pincodeItems: [KeychainPasswordItem] = []

    let localStorage = WalletsService()
    let animationController = AnimationController()

    //var newWallet: Bool = false

    var wallet: WalletModel?
    var password: String?

    convenience init(forWallet: WalletModel, with password: String) {
        self.init()
        wallet = forWallet
        self.password = password
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        disableBiometricsButton(true)
        changePincodeStatus(.new)
        numsIcons = [firstNum, secondNum, thirdNum, fourthNum]
    }

    func disableBiometrics() {
        biometricsButton.alpha = 0.0
        biometricsButton.isUserInteractionEnabled = false
    }

    func disableBiometricsButton(_ disable: Bool = false) {
        biometricsButton.alpha = disable ? 0.0 : 1.0
        biometricsButton.isUserInteractionEnabled = !disable
    }

    override func numberPressedAction(number: String) {
        if status == .new {
            pincode += number
            changeNumsIcons(pincode.count)
            if pincode.count == 4 {
                let newStatus: PincodeCreationStatus = .verify
                changePincodeStatus(newStatus)
            }
        } else if status == .verify {
            repeatedPincode += number
            changeNumsIcons(repeatedPincode.count)
            if repeatedPincode.count == 4 {
                let newStatus: PincodeCreationStatus = repeatedPincode == pincode ? .ready : .wrong
                changePincodeStatus(newStatus)
            }
        } else if status == .wrong {
            changePincodeStatus(.verify)
            repeatedPincode += number
            changeNumsIcons(repeatedPincode.count)
        }
    }

    override func deletePressedAction() {
        switch status {
        case .new:
            if pincode != "" {
                pincode.removeLast()
                changeNumsIcons(pincode.count)
            }
        default:
            if repeatedPincode != "" {
                repeatedPincode.removeLast()
                changeNumsIcons(repeatedPincode.count)
            }
        }
    }

    func changePincodeStatus(_ newStatus: PincodeCreationStatus) {
        status = newStatus
        messageLabel.text = status.rawValue
        if status == .wrong {
            repeatedPincode = ""
            changeNumsIcons(0)
        } else if status == .ready {
            createWallet()
        } else if status == .verify {
            changeNumsIcons(0)
        }
    }

    func createPassword() {
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPassword,
                    account: "\(self.wallet?.name ?? "")-password",
                    accessGroup: KeychainConfiguration.accessGroup)
            try passwordItem.savePassword(password ?? "")
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }

    func createWallet() {
        self.animationController.waitAnimation(isEnabled: true,
                                               notificationText: "Saving wallet",
                                               on: (self.view)!)
        DispatchQueue.global().async { [weak self] in
            UserDefaults.standard.set(true, forKey: "atLeastOneWalletExists")
            do {
                let pincodeItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPincode,
                                                       account: "pincode",
                                                       accessGroup: KeychainConfiguration.accessGroup)
                guard let pin = self?.pincode else {
                    fatalError("Error updating keychain - \(Errors.CommonErrors.unknown)")
                }
                try pincodeItem.savePassword(pin)
            } catch let error {
                fatalError("Error updating keychain - \(error)")
            }
            UserDefaults.standard.set(true, forKey: "pincodeExists")
            UserDefaults.standard.synchronize()
            
            self?.savingWallet()
        }
    }

    func savingWallet() {
        do {
            try localStorage.saveWallet(wallet: wallet!)
            self.createPassword()
            try localStorage.selectWallet(wallet: self.wallet!)
            if !UserDefaultKeys().tokensDownloaded {
                try TokensService().downloadAllAvailableTokensIfNeeded()
                UserDefaultKeys().setTokensDownloaded()
                UserDefaults.standard.synchronize()
            }
            
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            if !UserDefaultKeys().isEtherAdded {
                AppController().addFirstToken(for: self.wallet!, completion: { (error) in
                    if error == nil {
                        UserDefaultKeys().setEtherAdded()
                        UserDefaults.standard.synchronize()
                        dispatchGroup.leave()
                    } else {
                        fatalError("Can't add ether - \(String(describing: error))")
                    }
                })
            }
            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.animationController.waitAnimation(isEnabled: false,
                                                       on: (self?.view)!)
                if UserDefaultKeys().isEtherAdded {
                    self?.goToApp()
                } else {
                    Alerts().showErrorAlert(for: self!,
                                            error: Errors.NetworkErrors.wrongURL,
                                            completion: {
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
        } catch let error {
            fatalError("Error saving wallet - \(String(describing: error))")
        }
    }

    func goToApp() {
        DispatchQueue.main.async {
            let tabViewController = AppController().goToApp()
            tabViewController.view.backgroundColor = UIColor.white
            self.present(tabViewController, animated: true, completion: nil)
        }
    }
}
