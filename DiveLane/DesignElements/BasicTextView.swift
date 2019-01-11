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
        let height: CGFloat = Constants.buttons.heights.main
        let width: CGFloat = Constants.widthCoef * UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.frame = frame
        self.layer.cornerRadius = Constants.cornerRadius
        self.clipsToBounds = true
        
        self.backgroundColor = Colors.secondMain
        self.textColor = Colors.active
        self.textAlignment = .left
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
