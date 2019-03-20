//
//  QRiteractor.swift
//  Franklin
//
//  Created by Anton on 18/03/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import Foundation
import EthereumAddress

extension WalletViewController {
    func acceptQR(value: String) {
        if EthereumAddress(value) != nil {
            modalViewAppeared()
            let token = tokensArray[0].token
            showSend(token: token, address: value)
        } else if let url = URL(string: value) {
            if url.absoluteString.hasPrefix("ethereum:") {
                // TODO: - need ether check
                alerts.showErrorAlert(for: self, error: "No ethereum cheques yet", completion: nil)
            } else if url.absoluteString.hasPrefix("plasma:") {
                if let parsed = PlasmaParser.parse(url.absoluteString) {
                    let vc = AcceptChequeController(cheque: parsed)
                    navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                alerts.showErrorAlert(for: self, error: "Wrong URL", completion: nil)
            }
        } else {
            alerts.showErrorAlert(for: self, error: "Wrong QR code", completion: nil)
        }
    }
}
