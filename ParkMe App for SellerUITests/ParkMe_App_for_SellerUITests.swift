//
//  ParkMe_App_for_SellerUITests.swift
//  ParkMe App for SellerUITests
//
//  Created by Ely Benari on 12/8/16.
//  Copyright © 2016 Leor Benari. All rights reserved.
//

import XCTest

class ParkMe_App_for_SellerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func loginTest() {
        
        
        let app = XCUIApplication()
        let enterEmailTextField = app.textFields["Enter email"]
        enterEmailTextField.tap()
        enterEmailTextField.typeText("john@gmail.com")
        
        let enterPasswordSecureTextField = app.secureTextFields["Enter password"]
        enterPasswordSecureTextField.tap()
        enterPasswordSecureTextField.typeText("123456")
        app.buttons["Log In"].tap()
        
    }
    
    func registerTest() {
        
        let app = XCUIApplication()
        let enterEmailTextField = app.textFields["Enter email"]
        enterEmailTextField.tap()
        enterEmailTextField.typeText("newuser@gmail.com")
        
        let enterPasswordSecureTextField = app.secureTextFields["Enter password"]
        enterPasswordSecureTextField.tap()
        enterPasswordSecureTextField.typeText("123456")
        app.buttons["Sign Up"].tap()
        app.navigationBars["Sell or Request Spot"].buttons["Logout"].tap()
        
    }
    
    func sellSpotTest() {
        
        let app = XCUIApplication()
        let enterEmailTextField = app.textFields["Enter email"]
        enterEmailTextField.tap()
        enterEmailTextField.typeText("seller@gmail.com")
        
        let enterPasswordSecureTextField = app.secureTextFields["Enter password"]
        enterPasswordSecureTextField.tap()
        enterPasswordSecureTextField.typeText("123456")
        app.buttons["Log In"].tap()
        app.buttons["Sell Spot"].tap()
        
        let setPriceOfParkingSpotAlert = app.alerts["Set price of parking spot"]
        setPriceOfParkingSpotAlert.collectionViews.textFields["Enter amount"].typeText("3.33")
        setPriceOfParkingSpotAlert.buttons["Done"].tap()
        
    }
    
    func buySpotTest() {
        
        
        let app = XCUIApplication()
        let enterEmailTextField = app.textFields["Enter email"]
        enterEmailTextField.tap()
        enterEmailTextField.typeText("buyer@gmail.com")
        
        let enterPasswordSecureTextField = app.secureTextFields["Enter password"]
        enterPasswordSecureTextField.tap()
        enterPasswordSecureTextField.typeText("123456")
        app.buttons["Log In"].tap()
        app.buttons["Buy a Spot"].tap()
        app.tables.staticTexts["$4.00 - 0.0 miles away"].tap()
        app.buttons["Purchase Spot"].tap()
        app.alerts["Accepted"].buttons["Ok"].tap()
        app.alerts["Arrived at Parking Spot"].buttons["OK"].tap()
        
        
    }
    
}
