//
//  SendMoney+TextFieldDelegate.swift
//  Franklin
//
//  Created by Anton on 21/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension SendMoneyController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let newText = currentText.replacingCharacters(in: range, with: string) as String
        
        if textField == searchTextField {
            if newText == "" {
                getAllContacts()
            } else {
                let contact = newText
                searchContact(string: contact)
            }
            return true
        } else if textField == amountTextField && screenStatus != .saving {
            return check18afterDot(text: newText)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print(textField.tag)
        if textField == searchTextField {
            showSearch(animated: true)
        }
        return true
    }
}
