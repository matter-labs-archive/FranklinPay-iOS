//
//  TextViewExtension.swift
//  MatterWallet
//
//  Created by Anton Grigorev on 22/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

extension UITextView {
    func typeOn(string: String) {
        let characterArray = string.characterArray
        var characterIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if characterArray[characterIndex] != "$" {
                while characterArray[characterIndex] == " " {
                    self.text.append(" ")
                    characterIndex += 1
                    if characterIndex == characterArray.count {
                        timer.invalidate()
                        return
                    }
                }
                self.text.append(characterArray[characterIndex])
            }
            characterIndex += 1
            if characterIndex == characterArray.count {
                timer.invalidate()
            }
        }
    }
    
    func updateTextFont() {
        if (self.text.isEmpty || self.bounds.size.equalTo(CGSize.zero)) {
            return
        }
        
        let textViewSize = self.frame.size
        let fixedWidth = textViewSize.width
        let expectSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        
        var expectFont = self.font
        if (expectSize.height > textViewSize.height) {
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height) {
                expectFont = self.font!.withSize(self.font!.pointSize - 1)
                self.font = expectFont
            }
        } else {
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height) {
                expectFont = self.font
                self.font = self.font!.withSize(self.font!.pointSize + 1)
            }
            self.font = expectFont
        }
    }
}

extension UITextField {
    func typeOn(string: String) {
        let characterArray = string.characterArray
        var characterIndex = 0
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            if characterArray[characterIndex] != "$" {
                while characterArray[characterIndex] == " " {
                    self.text?.append(" ")
                    characterIndex += 1
                    if characterIndex == characterArray.count {
                        timer.invalidate()
                        return
                    }
                }
                self.text?.append(characterArray[characterIndex])
            }
            characterIndex += 1
            if characterIndex == characterArray.count {
                timer.invalidate()
            }
        }
    }
    
    func updateTextFont() {
        if (self.text?.isEmpty ?? true || self.bounds.size.equalTo(CGSize.zero)) {
            return
        }
        
        let textViewSize = self.frame.size
        let fixedWidth = textViewSize.width
        let expectSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        
        var expectFont = self.font
        if (expectSize.height > textViewSize.height) {
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > textViewSize.height) {
                expectFont = self.font!.withSize(self.font!.pointSize - 1)
                self.font = expectFont
            }
        } else {
            while (self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height) {
                expectFont = self.font
                self.font = self.font!.withSize(self.font!.pointSize + 1)
            }
            self.font = expectFont
        }
    }
}
