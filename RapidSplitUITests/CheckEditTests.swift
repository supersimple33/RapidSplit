//
//  CheckEditTests.swift
//  RapidSplitUITests
//
//  Created by Addison Hanrattie on 12/2/25.
//

import XCTest

final class CheckEditTests: AlertDismissingTestCase {

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        self.continueAfterFailure = false
        seedApp() // Ensure the app is installed and seeded
    }

    @MainActor
    func testDinnerPartyEditing() throws {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.staticTexts["Name"]/*[[".otherElements.staticTexts[\"Name\"]",".staticTexts[\"Name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        let element = app/*@START_MENU_TOKEN@*/.staticTexts["Dinner Party"]/*[[".buttons[\"Dinner Party, 2025-12-02 21:10:29 +0000\"].staticTexts",".buttons.staticTexts[\"Dinner Party\"]",".staticTexts[\"Dinner Party\"]"],[[[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.tap()

        let element2 = app/*@START_MENU_TOKEN@*/.images["list.bullet.rectangle"]/*[[".otherElements.images[\"list.bullet.rectangle\"]",".images[\"list.bullet.rectangle\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element2.tap()

        let priceField = app.textFields.matching(identifier: "Item Price").element(boundBy: 0)
        enterText("$23.00", into: priceField, in: app)

        let element3 = app.textFields.matching(identifier: "Item Name").element(boundBy: 0)
        enterText("Chicken", into: element3, in: app)
        app/*@START_MENU_TOKEN@*/.staticTexts["Add New Item"]/*[[".buttons",".staticTexts",".staticTexts[\"Add New Item\"]"],[[[-1,2],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        let element4 = app/*@START_MENU_TOKEN@*/.images["person.2"]/*[[".otherElements.images[\"person.2\"]",".images[\"person.2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element4.tap()

        let element5 = app.textFields.matching(identifier: "Phone").element(boundBy: 0)
        enterText("5551234567", into: element5, in: app, erasing: false, check: "(555) 123-4567")

        app/*@START_MENU_TOKEN@*/.buttons["Manually Add"]/*[[".otherElements.buttons[\"Manually Add\"]",".buttons[\"Manually Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        enterText("John", into: app.textFields["Enter First Name*"], in: app, erasing: false)
        enterText("Doe", into: app.textFields["Enter Last Name*"], in: app, erasing: false)
        app/*@START_MENU_TOKEN@*/.buttons["Add Participant"]/*[[".otherElements.buttons[\"Add Participant\"]",".buttons[\"Add Participant\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()

        app/*@START_MENU_TOKEN@*/.images["mail.and.text.magnifyingglass"]/*[[".otherElements.images[\"mail.and.text.magnifyingglass\"]",".images[\"mail.and.text.magnifyingglass\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.switches["assignmentToggle.New Item.John.Doe"].images["square"].firstMatch/*[[".images.matching(identifier: \"square\").element(boundBy: 8)",".switches[\"assignmentToggle.New Item.John.Doe\"]",".images.firstMatch",".images[\"Square\"].firstMatch",".images[\"square\"].firstMatch"],[[[-1,1,1],[-1,0]],[[-1,4],[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.switches["assignmentToggle.New Item.Gina.Lopez"].images["square"].firstMatch/*[[".images.matching(identifier: \"square\").element(boundBy: 7)",".switches[\"assignmentToggle.New Item.Gina.Lopez\"]",".images.firstMatch",".images[\"Square\"].firstMatch",".images[\"square\"].firstMatch"],[[[-1,1,1],[-1,0]],[[-1,4],[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["BackButton"].firstMatch.press(forDuration: 0.7)/*[[".navigationBars",".buttons.firstMatch",".tap()",".press(forDuration: 0.7)",".buttons[\"Receipts\"].firstMatch",".buttons[\"BackButton\"].firstMatch"],[[[-1,5,2],[-1,4,2],[-1,0,1]],[[-1,5,2],[-1,4,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/
        element.tap()
        element2.tap()
        element4.tap()
        app.windows.element(boundBy: 1).tap()
    }
}
