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
        return UIView(frame: CGRect(x: 0, y: 0, width: selfView.bounds.width, height: 30))
    }
    
    func tableViewHeaderWalletButton(in selfView: UIView, withTitle: String, withTag: Int) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: (selfView.bounds.width*3/4), height: 30))
        button.setTitle(withTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tag = withTag
        return button
    }
    
    func tableViewAddTokenButton(in selfView: UIView, withTitle: String, withTag: Int) -> UIButton {
        let button = UIButton(frame: CGRect(x: (selfView.bounds.width*3/4), y: 0, width: (selfView.bounds.width*1/4), height: 30))
        button.setTitle(withTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.tag = withTag
        return button
    }
}
