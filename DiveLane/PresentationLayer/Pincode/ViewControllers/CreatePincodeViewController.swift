//
//  CreateWalletPincodeViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 12/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class CreatePincodeViewController: PincodeViewController {
    
    let userDefaults = UserDefaultKeys()

    var pincode: String = ""
    var repeatedPincode: String = ""
    var status: PincodeCreationStatus = .new

    var pincodeItems: [KeychainPasswordItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        disableBiometricsButton(true)
        changePincodeStatus(.new)
        numsIcons = [firstNum, secondNum, thirdNum, fourthNum]
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
            savePincode()
        } else if status == .verify {
            changeNumsIcons(0)
        }
    }
    
    func savePincode() {
        DispatchQueue.global().async { [weak self] in
            do {
                let pincodeItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPincode,
                                                       account: "pincode",
                                                       accessGroup: KeychainConfiguration.accessGroup)
                guard let pin = self?.pincode else {
                    fatalError("Error updating keychain - \(Errors.CommonErrors.unknown)")
                }
                try pincodeItem.savePassword(pin)
                self?.userDefaults.setPincodeExists()
                self?.goToAddWallet()
            } catch let error {
                fatalError("Error updating keychain for pin - \(error)")
            }
        }
    }

    func goToAddWallet() {
        DispatchQueue.main.async {
            let vc = AppController().addWalletController()
            vc.view.backgroundColor = Colors.firstMain
            self.present(vc, animated: true, completion: nil)
        }
    }
}
