//
//  AppController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 08/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

class AppController {
    
    convenience init(
        window: UIWindow
        ) {
        self.init()
        start(in: window)
    }
    
    func start(in window: UIWindow) {
        window.rootViewController = StartViewController()
        window.makeKeyAndVisible()
    }
    
    
}

class StartViewController: UIViewController {
    
}

