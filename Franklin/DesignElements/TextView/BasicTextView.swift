//
//  BasicTextView.swift
//  DiveLane
//
//  Created by Anton Grigorev on 11/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class BasicTextView: UITextView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = Constants.TextView.cornerRadius
        self.clipsToBounds = true
        self.backgroundColor = Colors.background
        self.textColor = Colors.mainBlue
        self.layer.borderWidth = 2
        self.layer.borderColor = Colors.mostLightGray.cgColor
        self.textAlignment = .left
        self.font = UIFont(name: Constants.Fonts.regular,
                           size: Constants.TextView.maximumFontSize)
            ?? UIFont.systemFont(ofSize: Constants.TextView.maximumFontSize)
        //self.updateTextFont()
    }
}
