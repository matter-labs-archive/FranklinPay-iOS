//
//  BasicSeletedButton.swift
//  DiveLane
//
//  Created by Anton Grigorev on 11/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class BasicSelectedButton: UIButton {
    
    let animation = AnimationController()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let height: CGFloat = Constants.buttons.heights.main
        let heightContraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: height)
        self.addConstraint(heightContraint)
        self.layer.cornerRadius = height / 2
        self.clipsToBounds = true
        let font = UIFont(name: Constants.boldFont, size: Constants.basicFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.basicFontSize)
        self.titleLabel?.font = font
        self.backgroundColor = Colors.secondMain
        self.setTitleColor(Colors.firstMain, for: .normal)
        self.layer.borderWidth = 0.0
        //self.layer.borderColor = Colors.firstMain.cgColor
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchCancel)
        self.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDragInside)
        self.addTarget(self, action: #selector(buttonTouchedUp(_:)), for: .touchDragOutside)
    }
    
    @objc func buttonTouchedDown(_ sender: UIButton) {
        animation.pressButtonStartedAnimation(for: sender)
    }
    
    @objc func buttonTouchedUp(_ sender: UIButton) {
        animation.pressButtonCanceledAnimation(for: sender)
    }
}
