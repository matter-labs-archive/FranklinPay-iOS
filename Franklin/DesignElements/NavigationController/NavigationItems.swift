//
//  NavigationItems.swift
//  Franklin
//
//  Created by Anton on 22/02/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class NavigationItems {
    func homeItem(target: Any, action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "close_blue"), style: .plain, target: target, action: action)
    }
}
