//
//  TableHeader.swift
//  DiveLane
//
//  Created by Anton Grigorev on 11/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

@objc protocol TableHeaderDelegate: class {
    func didPressAdd(sender: UIButton)
}

class TableHeader: UIView {
    private let addButton = UIButton(type: .system)
    private let titleButton = UIButton(type: .system)
    weak var delegate: TableHeaderDelegate? {
        didSet {
            addButton.addTarget(delegate, action:  #selector(delegate?.didPressAdd(sender:)), for: .touchUpInside)
        }
    }
    
    init(for wallet: Wallet) {
        let height: CGFloat = Constants.Headers.Heights.tokens
        let width: CGFloat = UIScreen.main.bounds.width
        let coef: CGFloat = 0.7
        let const: CGFloat = 20
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)
        self.backgroundColor = Colors.background
        self.clipsToBounds = true
        
        titleButton.setTitle("Tokens", for: .normal)
        titleButton.setTitleColor(Colors.textBlack, for: .normal)
        titleButton.contentHorizontalAlignment = .left
        titleButton.titleLabel?.font = UIFont(name: Constants.Fonts.semibold, size: Constants.Headers.leftItemWalletFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.Headers.leftItemWalletFontSize)
        titleButton.frame = CGRect(x: const, y: 0, width: coef*(width-const), height: height)
        //titleButton.tag = section
        self.addSubview(titleButton)
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(Colors.textDarkGray, for: .normal)
        addButton.titleLabel?.font = UIFont(name: Constants.Fonts.regular, size: Constants.Headers.rightItemWalletFontSize) ?? UIFont.systemFont(ofSize: Constants.Headers.rightItemWalletFontSize)
        addButton.frame = CGRect(x: coef*(width-const), y: 0, width: (1-coef)*(width-const), height: height)
        addButton.backgroundColor = Colors.background
        addButton.contentHorizontalAlignment = .right
        addButton.layer.cornerRadius = height/2
        //addButton.tag = section
        self.addSubview(addButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
