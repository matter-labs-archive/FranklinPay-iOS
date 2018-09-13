//
//  EnterPincodeViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import LocalAuthentication

class EnterPincodeViewController: PincodeViewController {
    
    var pincode: String = ""
    var status: pincodeEnterStatus = .enter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changePincodeStatus(.enter)
        numsIcons = [firstNum, secondNum, thirdNum, fourthNum]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enterWithBiometrics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
        let context = LAContext()
        var error: NSError?
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricsButton.alpha = 0.0
            biometricsButton.isUserInteractionEnabled = false
        }
        
    }
    
    func changePincodeStatus(_ newStatus: pincodeEnterStatus) {
        status = newStatus
        messageLabel.text = status.rawValue
        if status == .wrong {
            pincode = ""
            changeNumsIcons(0)
        } else if status == .ready {
            enter()
        }
    }
    
    func checkPin(_ passcode: String) -> Bool {
        do {
            let pincodeItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: "THEMATTER",
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPincode = try pincodeItem.readPassword()
            return pincode == keychainPincode
        } catch {
            fatalError("Error reading password from keychain - \(error)")
        }
    }
    
    func enter() {
        DispatchQueue.main.async {
           
        }
    }
    
    override func numberPressedAction(number: String) {
        if status == .enter {
            pincode += number
            changeNumsIcons(pincode.count)
            if pincode.count == 4 {
                let newStatus: pincodeEnterStatus = checkPin(pincode) ? .ready : .wrong
                changePincodeStatus(newStatus)
            }
        } else if status == .wrong {
            changePincodeStatus(.enter)
            pincode += number
            changeNumsIcons(pincode.count)
        }
    }
    
    override func deletePressedAction() {
        if pincode != "" {
            pincode.removeLast()
            changeNumsIcons(pincode.count)
        }
    }
    
    override func biometricsPressedAction() {
        enterWithBiometrics()
    }
    
    func enterWithBiometrics() {
        
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            var type = "Touch ID"
            if #available(iOS 11, *) {
                switch(context.biometryType) {
                case .touchID:
                    type = "Touch ID"
                case .faceID:
                    type = "Face ID"
                case .none:
                    type = "Error"
                }
            }
            
            let reason = "Authenticate with " + type
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: reason,
                                   reply:
                { [weak self] (succes, error) in
                    
                    if succes {
                        self?.enter()
                    }
                    
            })
        }
    }
    
}
