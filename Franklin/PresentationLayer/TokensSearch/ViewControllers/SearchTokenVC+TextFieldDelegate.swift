//
//  SearchTokenVC+TextFieldDelegate.swift
//  Franklin
//
//  Created by Anton on 22/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension SearchTokenViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch currentScreen {
        case .search:
            let currentText = (textField.text ?? "") as NSString
            let newText = currentText.replacingCharacters(in: range, with: string) as String
            if newText == "" {
                emptyTokensList()
                makeHelpLabel(enabled: true)
            } else {
                let token = newText
                makeHelpLabel(enabled: false)
                searchTokens(string: token)
            }
            return true
        case .customToken:
            makeConfirmButton(enabled: areTokenFieldsFilled())
            switch textField.tag {
            case TextFieldsTags.decimals.rawValue:
                return textField.text?.count ?? 0 <= 9
            case TextFieldsTags.symbol.rawValue:
                return textField.text?.count ?? 0 <= 6
            default:
                return true
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if areTokenFieldsFilled() {
            return true
        } else {
            switch textField.tag {
            case TextFieldsTags.name.rawValue:
                tokenSymbolTextField.becomeFirstResponder()
            case TextFieldsTags.symbol.rawValue:
                tokenAddressTextField.becomeFirstResponder()
            case TextFieldsTags.address.rawValue:
                decimalsTextField.becomeFirstResponder()
            case TextFieldsTags.decimals.rawValue:
                decimalsTextField.resignFirstResponder()
            case TextFieldsTags.search.rawValue:
                searchTextField.resignFirstResponder()
            default:
                textField.resignFirstResponder()
            }
            return false
        }
    }
}
