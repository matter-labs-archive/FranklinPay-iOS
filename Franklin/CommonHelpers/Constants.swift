//
//  Constants.swift
//  DiveLane
//
//  Created by Anton Grigorev on 25.09.2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import UIKit

public struct Constants {
    
    static let commonWidthCoeff: CGFloat = 0.8
    
    public struct Main {
        static let animationDuration: TimeInterval = 0.25
    }
    
    public struct SideMenu {
        static let widthCoeff: CGFloat = 0.85
        static let shadowOpacity: Float = 0.5
        static let shadowRadius: CGFloat = 5
    }
    
    public struct SegmentedControl {
        static let maximumFontSize: CGFloat = 26
        static let minimumFontSize: CGFloat = 13
    }
    
    public struct TabBar {
        static let transitionsDuration: CFTimeInterval = 0.4
    }
    
    public struct ModalView {
        static let animationDuration: TimeInterval = 0.25
        static let animationSpeed: Float = 0.5
        public struct ContentView {
            static let cornerRadius: CGFloat = 30
            static let borderWidth: CGFloat = 1
            static let borderColor: CGColor = Colors.otherDarkGray.cgColor
            static let backgroundColor: UIColor = Colors.background
        }
        public struct ShadowView {
            static let tag = 1001
            static let alpha: CGFloat = 0.5
        }
    }
    
    public struct TableContact {
        static let cornerRadius: CGFloat = Constants.CollectionCell.Image.cornerRadius
        static let nameHeight: CGFloat = 30
        static let maximumFontSize: CGFloat = 18
        static let minimumFontSize: CGFloat = 11
        static let font: String = Constants.Fonts.regular
        static let addressHeight: CGFloat = 28
        static let height: CGFloat = 60
    }
    
    public struct Navigation {
        static let maximumFontSize: CGFloat = 26
        static let minimumFontSize: CGFloat = 13
    }
    
    public struct Button {
        static let animationDuration: TimeInterval = 0.05
        static let diffForSelectedInColor: CGFloat = 10
        static let cornerRadius: CGFloat = 10
        static let maximumFontSize: CGFloat = 26
        static let minimumFontSize: CGFloat = 13
        static let borderWidth: CGFloat = 1
        static let height: CGFloat = 60
    }
    
    public struct Fonts {
        static let franklinSemibold: String = "LibreFranklin-Semibold"
        static let franklinMedium: String = "LibreFranklin-Medium"
        static let regular: String = "SFProDisplay-Regular"
        static let bold: String = "SFProDisplay-Bold"
        static let semibold: String = "SFProDisplay-Semibold"
        static let medium: String = "SFProDisplay-Medium"
        static let light: String = "SFProDisplay-Light"
        static let heavy: String = "SFProDisplay-Heavy"
    }
    
    public struct TextField {
        static let cornerRadius: CGFloat = 10
        static let maximumFontSize: CGFloat = 22
        static let minimumFontSize: CGFloat = 11
        static let height: CGFloat = 59
    }
    
    public struct CommonLabel {
        static let height: CGFloat = 90
        static let maximumFontSize: CGFloat = 18
        static let minimumfontSize: CGFloat = 9
    }
    
    public struct Wallet {
        static let newPassword = "Matter"
        static let newName = "ETH Wallet"
    }
    
    public struct TextView {
        static let cornerRadius: CGFloat = 10
        static let maximumFontSize: CGFloat = 22
        static let minimumFontSize: CGFloat = 11
        static let height: CGFloat = 90
    }
    
    public struct CollectionCell {
        static let height: CGFloat = 100
        public struct Image {
            static let cornerRadius: CGFloat = 20
        }
    }
    
    public struct TokenCell {
        static let heightCoef: CGFloat = 0.35
        public struct Balance {
            static let font = Constants.Fonts.regular
            static let size: CGFloat = 40
            static let color = Colors.background
        }
        public struct Title {
            static let font = Constants.Fonts.franklinMedium
            static let size: CGFloat = 24
            static let color = Colors.cardGray
        }
        public struct BalanceLabel {
            static let font = Constants.Fonts.bold
            static let size: CGFloat = 12
            static let color = Colors.cardGray
        }
        public struct AccountNumberLabel {
            static let font = Constants.Fonts.bold
            static let size: CGFloat = 12
            static let color = Colors.cardGray
        }
        public struct AccountNumber {
            static let font = Constants.Fonts.regular
            static let size: CGFloat = 22
            static let color = Colors.background
        }
        
    }
    
    public struct TableCells {
        public struct Heights {
            static let settings: CGFloat = 45
            static let contacts: CGFloat = 120
            static let networks: CGFloat = 120
            static let wallets: CGFloat = 120
            static let tokens: CGFloat = 270
            static let additionalButtons: CGFloat = 40
        }
        static let boldFont = Constants.Fonts.bold
        static let regularFont = Constants.Fonts.regular
        static let maximumFontSize: CGFloat = 18
        static let minimumFontSize: CGFloat = 14
    }
    
    public struct Headers {
        static let maximumFontSize: CGFloat = 18
        static let minimumFontSize: CGFloat = 9
        public struct Heights {
            static let txHistory: CGFloat = 46
            static let wallets: CGFloat = 30
            static let tokens: CGFloat = 30
        }
    }
    
    public struct CollectionView {
        static let widthCoeff: CGFloat = 0.8 / 3
    }
}
