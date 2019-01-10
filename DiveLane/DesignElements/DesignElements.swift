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

public class DesignElements {
    public func navigationController(withTitle: String?, withImage: UIImage?,
                                     withController: UIViewController,
                                     tag: Int) -> UINavigationController {
        let nav = UINavigationController()
        nav.navigationBar.barTintColor = Colors.firstMain
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        nav.navigationBar.barStyle = .black
        let controller = withController
        controller.title = withTitle
        nav.viewControllers = [controller]
        nav.tabBarItem = UITabBarItem(title: nil, image: withImage, tag: tag)
        return nav
    }
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

class BasicSelectedButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let height: CGFloat = Constants.buttons.heights.main
        let width: CGFloat = Constants.widthCoef * UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.frame = frame
        self.layer.cornerRadius = height / 2
        self.clipsToBounds = true
        
        self.backgroundColor = Colors.secondMain
        self.setTitleColor(Colors.firstMain, for: .normal)
        self.layer.borderWidth = 0.0
        //self.layer.borderColor = Colors.firstMain.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BasicDeselectedButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let height: CGFloat = Constants.buttons.heights.main
        let width: CGFloat = Constants.widthCoef * UIScreen.main.bounds.width
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        self.frame = frame
        self.layer.cornerRadius = height / 2
        self.clipsToBounds = true
        
        self.backgroundColor = Colors.firstMain
        self.setTitleColor(Colors.secondMain, for: .normal)
        self.layer.borderWidth = 0.0
        //self.layer.borderColor = Colors.secondMain.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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

