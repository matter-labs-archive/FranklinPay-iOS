//
//  Constants.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

public struct Constants {
    
    static let widthCoef: CGFloat = 0.9
    static let horizontalConst: CGFloat = 20
    static let cornerRadius: CGFloat = 10
    static let font: String = "HelveticaNeue"
    static let boldFont: String = "HelveticaNeue-Bold"
    static let basicFontSize: CGFloat = 18
    static let smallFontSize: CGFloat = 14
    
    static let newWalletPassword = "Matter"
    static let newWalletName = "ETH Wallet"
    
    public struct textViews {
        public struct heights {
            static let main: CGFloat = 90
        }
    }
    public struct buttons {
        public struct heights {
            static let main: CGFloat = 50
            static let onboarding: CGFloat = 30
        }
        public struct widths {
            static let onboarding: CGFloat = 300
        }
    }
    public struct rows {
        public struct heights {
            static let settings: CGFloat = 80
            static let contacts: CGFloat = 120
            static let networks: CGFloat = 120
            static let wallets: CGFloat = 120
            static let tokens: CGFloat = 120
            static let additionalButtons: CGFloat = 40
        }
    }
    public struct headers {
        public struct heights {
            static let wallets: CGFloat = 30
            static let tokens: CGFloat = 30
        }
    }
    public struct segmentedControlls {
        public struct heights {
            static let wallets: CGFloat = 30
        }
    }
}
