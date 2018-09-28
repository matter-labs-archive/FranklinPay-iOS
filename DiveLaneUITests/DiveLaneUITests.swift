//
//  DiveLaneUITests.swift
//  DiveLaneUITests
//
//  Created by NewUser on 26/09/2018.
//  Copyright © 2018 Matter Inc. All rights reserved.
//

import XCTest

class DiveLaneUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        snapshot("MainScreen")
        let walletsNavigationBar = app.navigationBars["Wallets"]
        walletsNavigationBar.buttons["Add"].tap()
        snapshot("Wallets")
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["Info"]/*[[".cells.buttons[\"Info\"]",".buttons[\"Info\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("WalletInfo")
        app.navigationBars["Wallet"].buttons["Wallets"].tap()
        walletsNavigationBar.buttons["Wallets"].tap()
        tablesQuery.buttons["+"].tap()
        tablesQuery.searchFields["Search"].tap()
        snapshot("TokenSearch")
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["0x1ca43a170bad619322e6f54d46b57e504db663aa"]/*[[".cells.staticTexts[\"0x1ca43a170bad619322e6f54d46b57e504db663aa\"]",".staticTexts[\"0x1ca43a170bad619322e6f54d46b57e504db663aa\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Search token"].buttons["Wallets"].tap()
        
    }

}
