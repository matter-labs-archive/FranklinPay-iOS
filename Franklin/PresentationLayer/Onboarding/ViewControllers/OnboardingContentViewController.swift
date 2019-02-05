////
////  OnboardingContentViewController.swift
////  DiveLane
////
////  Created by Anton Grigorev on 08/09/2018.
////  Copyright © 2018 Matter Inc. All rights reserved.
////
//
//import UIKit
//
//class OnboardingContentViewController: UIViewController {
//
//    var pageIndex: Int!
//
//    func setViews() {
//
//        let titleAttr = [
//            NSAttributedString.Key.foregroundColor: Colors.textWhite,
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: Constants.basicFontSize, weight: .bold)
//        ]
//
//        let subtitleAttr = [
//            NSAttributedString.Key.foregroundColor: Colors.textWhite,
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: Constants.basicFontSize, weight: .light)
//        ]
//
//        let tv = UILabel()
//        tv.textAlignment = .center
//        let title = NSMutableAttributedString(string: PAGES[self.pageIndex].title, attributes: titleAttr)
//        tv.attributedText = title
//
//        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 0.8 * UIScreen.main.bounds.width, height: 100))
//        iv.contentMode = .scaleAspectFit
//        iv.image = PAGES[self.pageIndex].image
//
//        let stv = UILabel()
//        stv.textAlignment = .center
//        stv.numberOfLines = 0
//        let subtitle = NSMutableAttributedString(string: PAGES[self.pageIndex].subtitle, attributes: subtitleAttr)
//        stv.attributedText = subtitle
//
////        let views = [
////            "iv": iv,
////            "tv": tv,
////            "stv": stv
////        ]
//        let views = [
//            "iv": iv
//        ]
//        for (_, v) in views {
//            v.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(v)
//        }
//
//        let verticalCenter = NSLayoutConstraint(item: iv,
//                                                attribute: .centerY,
//                                                relatedBy: .equal,
//                                                toItem: self.view,
//                                                attribute: .centerY,
//                                                multiplier: 1,
//                                                constant: 0)
//        self.view.addConstraint(verticalCenter)
//        
//        NSLayoutConstraint.activate(
//            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[iv]-|",
//                                           options: .alignAllCenterX,
//                                           metrics: [:],
//                                           views: views) +
//            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[iv]-|",
//                                           options: .alignAllCenterX,
//                                           metrics: [:],
//                                           views: views)
//        )
//
////        NSLayoutConstraint.activate(
////            NSLayoutConstraint.constraints(withVisualFormat: "V:[iv]-20-[tv]-10-[stv]-(>=10)-|",
////                                               options: .alignAllCenterX,
////                                               metrics: [:],
////                                               views: views)  +
////            NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[tv]-20-|",
////                                           options: .alignAllCenterY,
////                                           metrics: [:],
////                                           views: views)  +
////            NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[stv]-20-|",
////                                           options: .alignAllCenterY,
////                                           metrics: [:],
////                                           views: views)
////        )
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = Colors.background
//        setViews()
//    }
//}
