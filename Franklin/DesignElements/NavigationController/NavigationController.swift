//
//  GeometricPrimitives.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

public func navigationController(withTitle: String?, withImage: UIImage?,
                                 withController: UIViewController,
                                 tag: Int) -> UINavigationController {
    let nav = UINavigationController()
    nav.navigationBar.barTintColor = Colors.background
    nav.navigationBar.tintColor = Colors.mainBlue
    let font = UIFont(name: Constants.Fonts.bold,
                      size: Constants.Navigation.maximumFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.Navigation.maximumFontSize)
    nav.navigationBar.titleTextAttributes = [
        NSAttributedString.Key.foregroundColor: Colors.mainBlue,
        NSAttributedString.Key.font: font
    ]
    let controller = withController
    controller.title = withTitle
    nav.viewControllers = [controller]
    nav.tabBarItem = UITabBarItem(title: nil, image: withImage, tag: tag)
    nav.tabBarItem.title = withTitle
    return nav
}

//class NavigationController: UINavigationController {
//
//    override func awakeFromNib() {
//        let font = UIFont(name: Constants.boldFont, size: Constants.basicFontSize) ?? UIFont.boldSystemFont(ofSize: Constants.basicFontSize)
//        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font]
//        self.navigationBar.barTintColor = Colors.firstMain
//        self.navigationBar.tintColor = Colors.secondMain
//    }
//}
