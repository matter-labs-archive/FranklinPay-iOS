//
//  TableHeader.swift
//  DiveLane
//
//  Created by Anton Grigorev on 11/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

//@objc protocol TableHeaderDelegate: class {
//    func didPressAdd(sender: UIButton)
//    func didPressExpand(sender: UIButton)
//}
//
//class TableHeader: UIView {
//    private let expandButton = UIButton(type: .system)
//    private let addButton = UIButton(type: .system)
//    weak var delegate: TableHeaderDelegate? {
//        didSet {
//            expandButton.addTarget(delegate, action:  #selector(delegate?.didPressExpand(sender:)), for: .touchUpInside)
//            addButton.addTarget(delegate, action:  #selector(delegate?.didPressAdd(sender:)), for: .touchUpInside)
//        }
//    }
//    
//    init(for wallet: Wallet, plasma: Bool, section: Int) {
//        let height: CGFloat = Constants.headers.heights.wallets
//        let width: CGFloat = UIScreen.main.bounds.width
//        let coef: CGFloat = 0.7
//        let frame = CGRect(x: 0, y: 0, width: width, height: height)
//        super.init(frame: frame)
//        self.backgroundColor = Colors.background
//        self.clipsToBounds = true
//        
//        expandButton.setTitle("\(wallet.name)", for: .normal)
//        expandButton.setTitleColor(Colors.textBlack, for: .normal)
//        expandButton.contentHorizontalAlignment = .left
//        expandButton.titleLabel?.font = UIFont(name: Constants.boldFont, size: Constants.basicFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.basicFontSize)
//        expandButton.frame = CGRect(x: Constants.horizontalConst, y: 0, width: coef*(width-Constants.horizontalConst), height: height)
//        expandButton.tag = section
//        self.addSubview(expandButton)
//        
//        if !plasma {
//            addButton.setTitle("Add token", for: .normal)
//            addButton.setTitleColor(Colors.textDarkGray, for: .normal)
//            addButton.titleLabel?.font = UIFont(name: Constants.semiboldFont, size: Constants.basicFontSize) ?? UIFont.systemFont(ofSize: Constants.basicFontSize)
//            addButton.frame = CGRect(x: coef*(width-Constants.horizontalConst), y: 0, width: (1-coef)*(width-Constants.horizontalConst), height: height)
//            addButton.backgroundColor = Colors.textBlack
//            addButton.layer.cornerRadius = height/2
//            addButton.tag = section
//            self.addSubview(addButton)
//        }
//        
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
