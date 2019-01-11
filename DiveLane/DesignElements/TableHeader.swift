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
    func didPressExpand(sender: UIButton)
}

class TableHeader: UIView {
    private let expandButton = UIButton(type: .system)
    private let addButton = UIButton(type: .system)
    weak var delegate: TableHeaderDelegate? {
        didSet {
            expandButton.addTarget(delegate, action:  #selector(TableHeaderDelegate.didPressExpand(sender:)), for: .touchUpInside)
            addButton.addTarget(delegate, action:  #selector(TableHeaderDelegate.didPressAdd(sender:)), for: .touchUpInside)
        }
    }
    
    init(for wallet: Wallet, plasma: Bool, section: Int) {
        let height: CGFloat = Constants.headers.heights.wallets
        let width: CGFloat = UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)
        self.backgroundColor = Colors.firstMain
        self.clipsToBounds = true
        
        expandButton.setTitle("Wallet \(wallet.name)", for: .normal)
        expandButton.setTitleColor(Colors.secondMain, for: .normal)
        expandButton.contentHorizontalAlignment = .left
        expandButton.titleLabel?.font = UIFont(name: Constants.boldFont, size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        expandButton.frame = CGRect(x: Constants.horizontalConst, y: 0, width: Constants.widthCoef*(width-Constants.horizontalConst), height: height)
        expandButton.tag = section
        self.addSubview(expandButton)
        
        if !plasma {
            addButton.setTitle("Add token", for: .normal)
            addButton.setTitleColor(Colors.secondMain, for: .normal)
            addButton.titleLabel?.font = UIFont(name: Constants.font, size: 20)  ?? UIFont.systemFont(ofSize: 20)
            addButton.frame = CGRect(x: Constants.widthCoef*(width-Constants.horizontalConst), y: 0, width: (1-Constants.widthCoef)*(width-Constants.horizontalConst), height: height)
            addButton.tag = section
            self.addSubview(addButton)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
