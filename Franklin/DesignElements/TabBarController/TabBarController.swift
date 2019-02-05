//
//  TabBarController.swift
//  Franklin
//
//  Created by Anton Grigorev on 23/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

import TransitionableTab

enum Type: String {
    case move
    case fade
    case scale
    case custom
    
    static var all: [Type] = [.move, .scale, .fade, .custom]
}

class TabBarController: UITabBarController {
    
    var type: Type = .custom
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
        self.delegate = self
    }
}

extension TabBarController: TransitionableTab {
    
    func transitionDuration() -> CFTimeInterval {
        return Constants.TabBar.transitionsDuration
    }
    
    func transitionTimingFunction() -> CAMediaTimingFunction {
        return .easeInOut
    }
    
    func fromTransitionAnimation(layer: CALayer?, direction: Direction) -> CAAnimation {
        switch type {
        case .move: return DefineAnimation.move(.from, direction: direction)
        case .scale: return DefineAnimation.scale(.from)
        case .fade: return DefineAnimation.fade(.from)
        case .custom:
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.fromValue = 0
            animation.toValue = direction == .right ? -(layer?.frame.width ?? 0) : (layer?.frame.width ?? 0)
            return animation
        }
    }
    
    func toTransitionAnimation(layer: CALayer?, direction: Direction) -> CAAnimation {
        switch type {
        case .move: return DefineAnimation.move(.to, direction: direction)
        case .scale: return DefineAnimation.scale(.to)
        case .fade: return DefineAnimation.fade(.to)
        case .custom:
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.fromValue = direction == .right ? (layer?.frame.width ?? 0) : -(layer?.frame.width ?? 0)
            animation.toValue = 0
            return animation
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return animateTransition(tabBarController, shouldSelect: viewController)
    }
}
