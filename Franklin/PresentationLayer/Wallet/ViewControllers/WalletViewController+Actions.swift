//
//  WalletViewController+ShowActions.swift
//  Franklin
//
//  Created by Anton on 20/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension WalletViewController {
    func deleteToken(in indexPath: IndexPath) {
        let token = tokensArray[indexPath.row].token
        let wallet = tokensArray[indexPath.row].inWallet
        let network = CurrentNetwork.currentNetwork
        let isEtherToken = token.isEther()
        let isDaiToken = token.isDai()
        let isCard = token.isFranklin() || token.isXDai()
        if isEtherToken {return}
        if isDaiToken {return}
        if isCard {return}
        do {
            try wallet.delete(token: token, network: network)
            CurrentToken.currentToken = tokensArray[0].token
            setTokensList()
        } catch let error {
            alerts.showErrorAlert(for: self, error: error, completion: nil)
        }
    }
    
    func showSend(token: ERC20Token, address: String) {
        modalViewAppeared()
        let sendMoneyVC = SendMoneyController(token: token, address: address)
        sendMoneyVC.delegate = self
        sendMoneyVC.modalPresentationStyle = .overCurrentContext
        sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
        tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
    }
    
    func showSend(token: ERC20Token) {
        modalViewAppeared()
        let sendMoneyVC = SendMoneyController(token: token)
        sendMoneyVC.delegate = self
        sendMoneyVC.modalPresentationStyle = .overCurrentContext
        sendMoneyVC.view.layer.speed = Constants.ModalView.animationSpeed
        tabBarController?.present(sendMoneyVC, animated: true, completion: nil)
    }
    
    func showAlert(error: String? = nil) {
        DispatchQueue.main.async { [unowned self] in
            self.alerts.showErrorAlert(for: self, error: error ?? "Unknown error", completion: nil)
        }
    }
}
