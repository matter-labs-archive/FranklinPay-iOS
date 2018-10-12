//
//  MaterialLabel.swift
//  DiveLane
//
//  Created by Francesco on 07/10/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

@IBDesignable class MaterialLabel: UILabel {

    // MARK: @IBInspectable Variables

    @IBInspectable var cornerRadius: CGFloat = 2
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowCardColor: UIColor? = .black
    @IBInspectable var shadowOpacity: Float = 0.5

    @IBInspectable var topInset: CGFloat = 10.0
    @IBInspectable var bottomInset: CGFloat = 10.0
    @IBInspectable var leftInset: CGFloat = 10.0
    @IBInspectable var rightInset: CGFloat = 10.0

    // MARK: Override

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: topInset,
            left: leftInset,
            bottom: bottomInset,
            right: rightInset
        )
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + leftInset + rightInset,
            height: size.height + topInset + bottomInset
        )
    }

    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        )

        layer.masksToBounds = false
        layer.shadowColor = shadowCardColor?.cgColor
        layer.shadowOffset = CGSize(
            width: shadowOffsetWidth,
            height: shadowOffsetHeight
        )
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
}

extension MaterialLabel {
    static var defaultMargins: UIEdgeInsets {
        return UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 15,
            right: 15)
    }
    static func makeInfoLabel() -> MaterialLabel {
        let label = MaterialLabel()
        label.backgroundColor = .white
        label.numberOfLines = 0
        label.layoutMargins = defaultMargins
        return label
    }
}
