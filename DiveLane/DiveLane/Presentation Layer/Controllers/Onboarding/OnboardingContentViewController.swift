//
//  OnboardingContentViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class OnboardingContentViewController: UIViewController {
    
    var pageIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lb = UILabel()
        lb.textAlignment = .center
        lb.text = PAGES[self.pageIndex].title
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = PAGES[self.pageIndex].image
        
        let views = [
            "iv": iv,
            "lb": lb
        ]
        for (_, v) in views {
            v.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(v)
        }
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[lb]-|",
                                           options: .alignAllCenterX,
                                           metrics: [:],
                                           views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-[iv]-|",
                                               options: .alignAllCenterX,
                                               metrics: [:],
                                               views: views) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lb]-[iv]-|",
                                               options: .alignAllCenterX,
                                               metrics: [:],
                                               views: views)
        )
    }
}
