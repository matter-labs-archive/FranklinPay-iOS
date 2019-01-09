//
//  GeometricPrimitives.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
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
        
        expandButton.setTitle("Wallet \(wallet.name)", for: .normal)
        expandButton.setTitleColor(Colors.secondMain, for: .normal)
        expandButton.contentHorizontalAlignment = .left
        expandButton.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
        expandButton.frame = CGRect(x: 20, y: 0, width: 0.8*(width-20), height: height)
        expandButton.tag = section
        self.addSubview(expandButton)
        
        if !plasma {
            addButton.setTitle("Add token", for: .normal)
            addButton.setTitleColor(Colors.secondMain, for: .normal)
            addButton.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
            addButton.frame = CGRect(x: 0.8*(width-20), y: 0, width: 0.2*(width-20), height: height)
            addButton.tag = section
            self.addSubview(addButton)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SegmentedControl: UISegmentedControl {
    override func awakeFromNib() {
        super.awakeFromNib()
        let height: CGFloat = Constants.segmentedControlls.heights.wallets
        let width: CGFloat = 0.8 * UIScreen.main.bounds.width
        self.frame.size = CGSize(width: width,
                                 height: height)
        self.tintColor = Colors.firstMain
        self.backgroundColor = Colors.active
        self.layer.cornerRadius = height/2
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = Colors.secondMain.cgColor
    }
}
