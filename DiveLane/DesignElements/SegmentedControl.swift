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
        let height: CGFloat = Constants.segmentedControlls.heights.wallets
        let width: CGFloat = Constants.widthCoef * UIScreen.main.bounds.width
        self.frame = CGRect(x: 0, y: 0, width: width, height: height)
        let font = UIFont(name: Constants.boldFont, size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        self.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        self.tintColor = Colors.firstMain
        self.backgroundColor = Colors.secondMain
        self.layer.cornerRadius = height/2
        self.clipsToBounds = true
        self.layer.borderWidth = 0.0
        //        self.layer.borderColor = Colors.secondMain.cgColor
    }
}
