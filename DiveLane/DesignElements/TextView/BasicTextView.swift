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
        self.layer.cornerRadius = Constants.cornerRadius
        self.clipsToBounds = true
        
        self.backgroundColor = Colors.secondMain
        self.textColor = Colors.active
        self.textAlignment = .left
    }
}
