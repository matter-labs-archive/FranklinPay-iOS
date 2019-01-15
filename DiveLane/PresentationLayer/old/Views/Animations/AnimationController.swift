//
//  AnimationController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 12/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class AnimationController: UIView {

    enum TagsForViews: Int {
        case background = 776
        case notification = 775
        case animation = 777
        case imageView = 778
    }

    /*
     Wait animation for load screens:
     isEnabled - true or false
     notificationText - text in the screens center
     view - superview for animation view
     */
    func waitAnimation(isEnabled: Bool, notificationText: String? = nil, on view: UIView) {

        DispatchQueue.main.async {
            if isEnabled {

                let centerX = UIScreen.main.bounds.size.width / 2
                let centerY = UIScreen.main.bounds.size.height / 2

                view.alpha = 1.0

                let rect: CGRect = CGRect(x: 0,
                        y: 0,
                        width: UIScreen.main.bounds.size.width,
                        height: UIScreen.main.bounds.size.height)
                let background: UIView = UIView(frame: rect)
                background.backgroundColor = UIColor.white
                background.alpha = 1
                background.tag = TagsForViews.background.rawValue

                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 134, height: 117))
                imageView.image = UIImage(named: "onboarding2")
                imageView.center = CGPoint(x: centerX, y: centerY - 70)
                imageView.tag = TagsForViews.imageView.rawValue

                let notification: UILabel = UILabel.init(frame: CGRect(x: 0,
                        y: 0,
                        width: UIScreen.main.bounds.size.width,
                        height: 20))
                notification.textColor = UIColor.darkGray
                notification.textAlignment = NSTextAlignment.center
                notification.font = UIFont(name: Constants.font, size: Constants.basicFontSize)
                notification.numberOfLines = 1
                notification.center = CGPoint(x: centerX, y: centerY + 10)
                notification.tag = TagsForViews.notification.rawValue
                notification.text = notificationText ?? ""

                let animation: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
                var frame: CGRect = animation.frame
                frame.origin.x = centerX - 10
                frame.origin.y = centerY + 50
                frame.size.width = 20
                frame.size.height = 20
                animation.frame = frame
                animation.tag = TagsForViews.animation.rawValue

                view.insertSubview(background, at: 5)
                view.insertSubview(imageView, at: 6)
                view.insertSubview(animation, at: 7)
                view.insertSubview(notification, at: 8)

                animation.startAnimating()
            } else {
                view.alpha = 1.0
                if let viewWithTag = view.viewWithTag(TagsForViews.notification.rawValue) {
                    viewWithTag.removeFromSuperview()
                }
                if let viewWithTag = view.viewWithTag(TagsForViews.imageView.rawValue) {
                    viewWithTag.removeFromSuperview()
                }
                if let viewWithTag = view.viewWithTag(TagsForViews.background.rawValue) {
                    viewWithTag.removeFromSuperview()
                }
                if let viewWithTag = view.viewWithTag(TagsForViews.animation.rawValue) {
                    viewWithTag.removeFromSuperview()
                }
            }
        }

    }

    func pressButtonStartedAnimation(for sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05,
                    animations: {
                        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    },
                    completion: nil)
        }

    }

    func pressButtonCanceledAnimation(for sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.05) {
                sender.transform = CGAffineTransform.identity
            }
        }

    }

}
