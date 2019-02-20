//
//  SegmentedControl.swift
//  DiveLane
//
//  Created by Anton Grigorev on 11/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//
import UIKit

class SegmentedControl: UISegmentedControl {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont(name: Constants.Fonts.bold, size: Constants.SegmentedControl.maximumFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.SegmentedControl.maximumFontSize)
        self.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        self.tintColor = Colors.textWhite
        self.backgroundColor = Colors.mainBlue
        self.layer.cornerRadius = self.frame.height/2
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Colors.mainBlue.cgColor
    }
}
