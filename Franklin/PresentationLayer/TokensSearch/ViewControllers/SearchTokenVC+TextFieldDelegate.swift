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
    }
}
