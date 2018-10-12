//
//  UIView+Extensions.swift
//  DiveLane
//
//  Created by Francesco on 06/10/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

extension UIView {

    class func loadFromNib<T: UIView>() -> T? {
        guard let view = Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as? T else { return nil }
        return view
    }

    public func anchorToSuperview(withEdges edges: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        guard let superView = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: edges.left),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -edges.right),
            topAnchor.constraint(equalTo: superView.topAnchor, constant: edges.top),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -edges.bottom)
            ])
    }
}
