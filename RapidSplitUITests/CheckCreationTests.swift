//
//  CheckCreationTests.swift
//  RapidSplitUITests
//
//  Created by Addison Hanrattie on 11/25/25.
//

import XCTest

fileprivate let IMAGE_LINK = "https://raw.githubusercontent.com/supersimple33/RapidSplit/refs/heads/test/AddingUITests/RapidSplitUITests/media/check.jpg"

final class CheckCreationTests: XCTestCase {

    @MainActor
    override func setUp() async throws {
        self.continueAfterFailure = false
        resetApp() // Ensure the app is installed and no exisiting checks
    }

    @MainActor
    func testCheckCreation() throws {
        let app = XCUIApplication()
        openPhotoInApp(link: IMAGE_LINK)
        app.activate()

        // Add a new item
        let addItemButton = app.buttons["Add New Item"]
        XCTAssertTrue(addItemButton.waitForExistence(timeout: 25), "Expected a 'Add New Item' button to appear")
        addItemButton.tap()
        // Check an item text field appeared; prefer the focused 'Item Name' field
        let itemNameFields = app.textFields.matching(NSPredicate(format: "placeholderValue == %@", "Item Name"))
        let nameTextField = itemNameFields.element(boundBy: 0)
        XCTAssertTrue(nameTextField.waitForExistence(timeout: 5), "Expected an 'Item Name' text field to appear")
        enterText("Groceries", into: nameTextField, in: app)
        // check there is a price field
        let itemPriceFields = app.textFields.matching(NSPredicate(format: "placeholderValue == %@", "Item Price"))
        let priceTextField = itemPriceFields.element(boundBy: 0)
        XCTAssertTrue(priceTextField.waitForExistence(timeout: 5), "Expected an 'Item Name' text field to appear")
        enterText("$21.00", into: priceTextField, in: app)

        // Move onto the next page
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 3), "Expected a 'Continue' button to appear")
        continueButton.tap()


        // Add Anna Haro
        let importContact = app.buttons["Import from Contacts"]
        XCTAssertTrue(importContact.waitForExistence(timeout: 3), "Expected a 'Manually Add' button to appear")
        importContact.tap()
        let contact = findElement(named: "Anna Haro", in: app)
        XCTAssertTrue(contact.waitForExistence(timeout: 5), "Anna Haro not found anywhere")
        contact.tap()
        // Verify that Anna Haro now appears on screen after selection
        let annaLabel = app.textFields["Anna"]
        XCTAssertTrue(annaLabel.waitForExistence(timeout: 5), "Expected 'Anna' to be visible on screen after selecting the contact")
        let haroLabel = app.textFields["Haro"]
        XCTAssertTrue(haroLabel.waitForExistence(timeout: 5), "Expected 'Haro' to be visible on screen after selecting the contact")

        // Add Custom Contact
        let addContact = app.buttons["Manually Add"]
        XCTAssertTrue(addContact.waitForExistence(timeout: 3), "Expected a 'Manually Add' button to appear")
        addContact.tap()

        // Write name and phone
        let firstNameFields = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] %@", "Enter First Name"))
        let firstNameTextField = firstNameFields.element(boundBy: 0)
        XCTAssertTrue(firstNameTextField.waitForExistence(timeout: 5), "Expected an 'First Name' text field to appear")
        enterText("John", into: firstNameTextField, in: app)
        let lastNameFields = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] %@", "Enter Last Name"))
        let lastNameTextField = lastNameFields.element(boundBy: 0)
        XCTAssertTrue(lastNameTextField.waitForExistence(timeout: 5), "Expected an 'Last Name' text field to appear")
        enterText("Doe", into: lastNameTextField, in: app)
        let phoneFields = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] %@", "Enter Phone Number"))
        let phoneTextField = phoneFields.element(boundBy: 0)
        XCTAssertTrue(phoneTextField.waitForExistence(timeout: 5), "Expected an 'Phone Number' text field to appear")
        enterText("6825552419", into: phoneTextField, in: app)
        // Confirm the new contact
        let confirmContact = app.buttons["Add Participant"]
        XCTAssertTrue(confirmContact.waitForExistence(timeout: 3), "Expected a 'Add Participant' button to appear")
        confirmContact.tap()
        // Verify the text was set
        XCTAssertTrue(app.textFields["John"].waitForExistence(timeout: 5), "Expected 'John' to be visible on screen after creating the contact")
        XCTAssertTrue(app.textFields["Doe"].waitForExistence(timeout: 5), "Expected 'Doe' to be visible on screen after creating the contact")
        XCTAssertTrue(app.textFields["(682) 555-2419"].waitForExistence(timeout: 5), "Expected 'Phone Number' to be visible on screen after creating the contact")

        // Move onto the next page
        let secondContinueButton = app.buttons["Continue"]
        XCTAssertTrue(secondContinueButton.waitForExistence(timeout: 3), "Expected a 'Continue' button to appear")
        secondContinueButton.tap()

        // Assign Items
        let johnAssignmentButton = app.switches["assignmentToggle.Groceries.John.Doe"]
        XCTAssertTrue(johnAssignmentButton.waitForExistence(timeout: 3), "Expected a 'assignment' toggle to appear")
        johnAssignmentButton.tap()
        let annaAssignmentButton = app.switches["assignmentToggle.Groceries.Anna.Haro"]
        XCTAssertTrue(annaAssignmentButton.waitForExistence(timeout: 3), "Expected a 'assignment' toggle to appear")
        annaAssignmentButton.tap()

        // Finalize Check
        let finalizeButton = app.buttons["Finish Assignment"]
        XCTAssertTrue(finalizeButton.waitForExistence(timeout: 3), "Expected a 'Finish Assignment' button to appear")
        finalizeButton.tap()

        // Mark Payout
        let johnPayButton = app.buttons["payout.John.Doe"]
        XCTAssertTrue(johnPayButton.waitForExistence(timeout: 3), "Expected a 'Payout' button to appear")
        johnPayButton.tap()
        let markPaidButton = app.buttons["Mark As Paid"]
        XCTAssertTrue(markPaidButton.waitForExistence(timeout: 3), "Expected a 'Mark As Paid' button to appear")
        markPaidButton.tap()

        // Navigate out and back into
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Expected a 'Back' button to appear")
        backButton.tap()

        let dateButton = app.staticTexts["Date"]
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Expected a 'Date' button to appear")
        dateButton.tap()
        dateButton.tap()

        let checkButton = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS[c] %@", "checkRow.")
        ).firstMatch
        XCTAssertTrue(checkButton.waitForExistence(timeout: 3), "Expected a 'Check Row' button to appear")
        checkButton.tap()

        let subtotalButton = app.buttons["Subtotal"]
        XCTAssertTrue(subtotalButton.waitForExistence(timeout: 3), "Expected a 'subtotal' button to appear")
        let priceOwedLabel = app.staticTexts["$21.00"]
        XCTAssertTrue(priceOwedLabel.waitForExistence(timeout: 5), "Expected '$21.00' to be visible on screen after selecting the contact")
    }
}

