//
//  BasicSeletedButton.swift
//  DiveLane
//
//  Created by Anton Grigorev on 11/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class BasicGreenButton: UIButton {
    
    let animation = AnimationController()
    
    override func awakeFromNib() {
        self.layer.cornerRadius = Constants.Button.cornerRadius
        self.clipsToBounds = true
        let font = UIFont(name: Constants.Fonts.regular, size: Constants.Button.maximumFontSize) ?? UIFont.systemFont(ofSize: Constants.Button.maximumFontSize)
        self.titleLabel?.font = font
        self.backgroundColor = Colors.mainGreen
        self.setTitleColor(Colors.textWhite, for: .normal)
        self.layer.borderWidth = Constants.Button.borderWidth
        self.layer.borderColor = Colors.background.cgColor
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpOutside)
    }
    
    @objc func buttonTouchedDown(_ sender: UIButton) {
        animation.pressButtonStartedAnimation(for: sender, color: Colors.mainGreen)
    }
    
    @objc func buttonTouchedUp(_ sender: UIButton) {
        animation.pressButtonCanceledAnimation(for: sender, color: Colors.mainGreen)
    }
}

class BasicBlueButton: UIButton {
    
    let animation = AnimationController()
    
    override func awakeFromNib() {
        self.layer.cornerRadius = Constants.Button.cornerRadius
        self.clipsToBounds = true
        let font = UIFont(name: Constants.Fonts.regular, size: Constants.Button.maximumFontSize) ?? UIFont.systemFont(ofSize: Constants.Button.maximumFontSize)
        self.titleLabel?.font = font
        self.backgroundColor = Colors.mainBlue
        self.setTitleColor(Colors.textWhite, for: .normal)
        self.layer.borderWidth = Constants.Button.borderWidth
        self.layer.borderColor = Colors.background.cgColor
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpOutside)
    }
    
    @objc func buttonTouchedDown(_ sender: UIButton) {
        animation.pressButtonStartedAnimation(for: sender, color: Colors.mainBlue)
    }
    
    @objc func buttonTouchedUp(_ sender: UIButton) {
        animation.pressButtonCanceledAnimation(for: sender, color: Colors.mainBlue)
    }
}

class BasicWhiteButton: UIButton {
    
    let animation = AnimationController()
    
    var currentBackgroundColor: UIColor?
    
    override func awakeFromNib() {
        self.layer.cornerRadius = Constants.Button.cornerRadius
        self.clipsToBounds = true
        let font = UIFont(name: Constants.Fonts.regular, size: Constants.Button.maximumFontSize) ?? UIFont.systemFont(ofSize: Constants.Button.maximumFontSize)
        self.titleLabel?.font = font
        self.backgroundColor = Colors.background
        self.setTitleColor(Colors.mainBlue, for: .normal)
        self.layer.borderWidth = 1
        self.layer.borderColor = Colors.mainBlue.cgColor
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpOutside)
    }
    
    func changeColorOn(background color: UIColor, text: UIColor) {
        self.backgroundColor = color
        self.setTitleColor(text, for: .normal)
        self.currentBackgroundColor = color
    }
    
    @objc func buttonTouchedDown(_ sender: UIButton) {
        animation.pressButtonStartedAnimation(for: sender, color: self.currentBackgroundColor ?? Colors.background)
    }
    
    @objc func buttonTouchedUp(_ sender: UIButton) {
        animation.pressButtonCanceledAnimation(for: sender, color: self.currentBackgroundColor ?? Colors.background)
    }
}

class BasicOrangeButton: UIButton {
    
    let animation = AnimationController()
    
    override func awakeFromNib() {
        self.layer.cornerRadius = Constants.Button.cornerRadius
        self.clipsToBounds = true
        let font = UIFont(name: Constants.Fonts.regular, size: Constants.Button.maximumFontSize) ?? UIFont.systemFont(ofSize: Constants.Button.maximumFontSize)
        self.titleLabel?.font = font
        self.backgroundColor = Colors.orange
        self.setTitleColor(Colors.textWhite, for: .normal)
        self.layer.borderWidth = 0
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpOutside)
    }
    
    @objc func buttonTouchedDown(_ sender: UIButton) {
        animation.pressButtonStartedAnimation(for: sender, color: Colors.orange)
    }
    
    @objc func buttonTouchedUp(_ sender: UIButton) {
        animation.pressButtonCanceledAnimation(for: sender, color: Colors.orange)
    }
}

class ScanButton: UIButton {
    
    let animation = AnimationController()
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.backgroundColor = UIColor.white
        self.setBackgroundImage(UIImage(named: "photo"), for: .normal)
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchDragOutside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchUpOutside)
    }
    
    @objc func buttonTouchedDown(_ sender: UIButton) {
    }
    
    @objc func buttonTouchedUp(_ sender: UIButton) {
    }
}
