//
//  EnterPincodeViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 13/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit
import LocalAuthentication
import Web3swift
import PlasmaSwiftLib

class EnterPincodeViewController: PincodeViewController {

    var pincode: String = ""
    var status: PincodeEnterStatus = .enter

    var fromCase: EnterPincodeFromCases?
    var data: [String: Any]?
    var transaction: Transaction?
    var password: String?
    var isFromDeepLink: Bool = false
    var isContract: Bool = false

    var transactionService = Web3Service()
    let keysService = WalletsService()

    let animationController = AnimationController()

    convenience init(from: EnterPincodeFromCases, for data: [String: Any], isContract: Bool = false, withPassword: String, isFromDeepLink: Bool) {
        self.init()
        fromCase = from
        self.data = data
        self.password = withPassword
        self.isFromDeepLink = isFromDeepLink
        self.isContract = isContract
    }

    convenience init(from: EnterPincodeFromCases, for transaction: Transaction, withPassword: String, isFromDeepLink: Bool) {
        self.init()
        fromCase = from
        self.transaction = transaction
        self.password = withPassword
        self.isFromDeepLink = isFromDeepLink
    }

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
            hideBiometricsButton(true)
            biometricsButton.isUserInteractionEnabled = false
        }

    }

    func hideBiometricsButton(_ hidden: Bool = false) {
        biometricsButton.alpha = hidden ? 0.0 : 1.0
    }

    func changePincodeStatus(_ newStatus: PincodeEnterStatus) {
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
            let pincodeItem = KeychainPasswordItem(service: KeychainConfiguration.serviceNameForPincode,
                    account: "pincode",
                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPincode = try pincodeItem.readPassword()
            return pincode == keychainPincode
        } catch {
            fatalError("Error reading password from keychain - \(error)")
        }
    }

    func enter() {

        switch fromCase ?? .enterWallet {
        case .transaction:
            animationController.waitAnimation(isEnabled: true, notificationText: "Sending transaction", on: self.view)
            if data != nil {
                let transactionData = transactionService.getDataForTransaction(dict: data!)
                send(with: transactionData)
            } else if let t = transaction {
                send(with: t)
            }
        default:
            let startViewController = AppController().goToApp()
            startViewController.view.backgroundColor = UIColor.white
            UIApplication.shared.keyWindow?.rootViewController = startViewController
        }
    }

    func send(with transaction: Transaction) {
        guard let wallet = try? keysService.getSelectedWallet() else {return}
        guard let pass = password else {return}
        guard let privateKey = try? keysService.getPrivateKey(for: wallet, password: pass) else {return}
        let privKey = Data(hex: privateKey)
        guard let signedTransaction = try? transaction.sign(privateKey: privKey) else {return}

        guard let result = try? PlasmaService().sendRawTX(transaction: signedTransaction, onTestnet: true) else {
            DispatchQueue.main.async { [weak self] in
                Alerts().showErrorAlert(for: self!, error: Errors.CommonErrors.unknown, completion: {
                    self?.returnToStartTab()
                })
            }
            return
        }
        if !result {
            Alerts().showErrorAlert(for: self, error: nil, completion: {
                self.returnToStartTab()
            })
            return
        }
        DispatchQueue.main.async { [weak self] in
            Alerts().showSuccessAlert(for: self!, completion: {
                self?.returnToStartTab()
            })
        }
    }

    func send(with data: (transaction: WriteTransaction, options: TransactionOptions)) {
        do {
            let _ = try transactionService.sendTx(transaction: data.transaction, options: data.options, password: password!)
            DispatchQueue.main.async { [weak self] in
                self?.animationController.waitAnimation(isEnabled: false, on: (self?.view)!)
            }
            Alerts().showSuccessAlert(for: self, completion: { [weak self] in
                self?.returnToStartTab()
            })
        } catch {
            return
        }
    }

    func returnToStartTab() {
        let startViewController = AppController().goToApp()
        startViewController.view.backgroundColor = UIColor.white
        UIApplication.shared.keyWindow?.rootViewController = startViewController
    }

    override func numberPressedAction(number: String) {
        if status == .enter {
            pincode += number
            changeNumsIcons(pincode.count)
            if pincode.count == 4 {
                let newStatus: PincodeEnterStatus = checkPin(pincode) ? .ready : .wrong
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
                switch context.biometryType {
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
                    reply: { [weak self] (succes, _) in

                        if succes {
                            self?.enter()
                        }

                    })
        }
    }

}
