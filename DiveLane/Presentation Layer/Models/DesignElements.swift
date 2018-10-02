//
//  GeometricPrimitives.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class DesignElements: UIView {
    func tableViewHeaderBackground(in selfView: UIView) -> UIView {
        let background = UIView(frame: CGRect(x: 20, y: 0, width: selfView.bounds.width, height: 45))
        background.backgroundColor = .white
        
        let topSeparator = UIView(frame: CGRect(x: 20, y: 0, width: selfView.bounds.width - 25, height: 1))
        topSeparator.backgroundColor = .lightGray
        
        let bottomSeparator = UIView(frame: CGRect(x: 20, y: 45, width: selfView.bounds.width - 25, height: 1))
        bottomSeparator.backgroundColor = .lightGray
        
        background.addSubview(topSeparator)
        //background.addSubview(bottomSeparator)
        
        return background
    }

    func tableViewHeaderWalletButton(in selfView: UIView, withTitle: String, withTag: Int) -> UIButton {
        let button = UIButton(frame:
            CGRect(x: 20,
                   y: 0,
                   width: selfView.bounds.width - 45,
                   height: 45)
        )
        button.setTitle(withTitle, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.tag = withTag
        return button
    }

    func tableViewAddTokenButton(in selfView: UIView, withTitle: String, withTag: Int) -> UIButton {
        let button = UIButton(frame:
            CGRect(x: selfView.bounds.width - 45,
                   y: 0,
                   width: 45,
                   height: 45)
        )
        button.setTitle(withTitle, for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .light)
        button.tag = withTag
        return button
    }
}
