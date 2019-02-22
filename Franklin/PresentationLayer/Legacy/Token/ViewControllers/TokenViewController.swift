//
//  TokenViewController.swift
//  DiveLane
//
//  Created by Anton Grigorev on 14/01/2019.
//  Copyright © 2019 Matter Inc. All rights reserved.
//

import UIKit

class TokenViewController: BasicViewController {
    
    convenience init(destinationAddress: String) {
        self.init()
    }
    
    convenience init(token: ERC20Token) {
        self.init()
    }
    
    convenience init(amount: String, destinationAddress: String, isFromDeepLink: Bool) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
