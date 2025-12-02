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
        tapButton("Add New Item", in: app, timeout: 25)
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
        tapButton("Continue", in: app)

        // Add Anna Haro
        tapButton("Import from Contacts", in: app)
        let contact = findElement(named: "Anna Haro", in: app)
        XCTAssertTrue(contact.waitForExistence(timeout: 5), "Anna Haro not found anywhere")
        contact.tap()
        // Verify that Anna Haro now appears on screen after selection
        let annaLabel = app.textFields["Anna"]
        XCTAssertTrue(annaLabel.waitForExistence(timeout: 5), "Expected 'Anna' to be visible on screen")
        let haroLabel = app.textFields["Haro"]
        XCTAssertTrue(haroLabel.waitForExistence(timeout: 5), "Expected 'Haro' to be visible on screen")

        // Add Custom Contact
        tapButton("Manually Add", in: app)

        // Write name and phone
        let firstNameFields = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] %@", "Enter First Name"))
        let firstNameTextField = firstNameFields.element(boundBy: 0)
        XCTAssertTrue(firstNameTextField.waitForExistence(timeout: 5), "Expected an 'First Name' text field to appear")
        enterText("John", into: firstNameTextField, in: app, erasing: false)
        let lastNameFields = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] %@", "Enter Last Name"))
        let lastNameTextField = lastNameFields.element(boundBy: 0)
        XCTAssertTrue(lastNameTextField.waitForExistence(timeout: 5), "Expected an 'Last Name' text field to appear")
        enterText("Doe", into: lastNameTextField, in: app, erasing: false)
        let phoneFields = app.textFields.matching(NSPredicate(format: "placeholderValue CONTAINS[c] %@", "Enter Phone Number"))
        let phoneTextField = phoneFields.element(boundBy: 0)
        XCTAssertTrue(phoneTextField.waitForExistence(timeout: 5), "Expected an 'Phone Number' text field to appear")
        enterText("6825552419", into: phoneTextField, in: app, erasing: false)
        // Confirm the new contact
        tapButton("Add Participant", in: app)
        // Verify the text was set
        XCTAssertTrue(app.textFields["John"].waitForExistence(timeout: 3), "Expected 'John' to be visible on screen after creating the contact")
        XCTAssertTrue(app.textFields["Doe"].waitForExistence(timeout: 3), "Expected 'Doe' to be visible on screen after creating the contact")
        XCTAssertTrue(app.textFields["(682) 555-2419"].waitForExistence(timeout: 3), "Expected 'Phone Number' to be visible on screen after creating the contact")

        // Move onto the next page
        tapButton("Continue", in: app)

        // Assign Items
        let johnAssignmentButton = app.switches["assignmentToggle.Groceries.John.Doe"]
        XCTAssertTrue(johnAssignmentButton.waitForExistence(timeout: 3), "Expected a 'assignment' toggle to appear")
        johnAssignmentButton.tap()
        let annaAssignmentButton = app.switches["assignmentToggle.Groceries.Anna.Haro"]
        XCTAssertTrue(annaAssignmentButton.waitForExistence(timeout: 3), "Expected a 'assignment' toggle to appear")
        annaAssignmentButton.tap()

        // Finalize Check
        tapButton("Finish Assignment", in: app)

        // Mark Payout
        tapButton("payout.John.Doe", in: app)
        tapButton("Mark As Paid", in: app)

        // Navigate out and back into
        tapButton("BackButton", in: app)

        // Verify we can interact with date sorting
        let dateButton = app.staticTexts["Date"]
        XCTAssertTrue(dateButton.waitForExistence(timeout: 3), "Expected a 'Date' button to appear")
        dateButton.tap()
        dateButton.tap()

        // Move back into the check
        let checkButton = app.buttons.matching(
            NSPredicate(format: "identifier CONTAINS[c] %@", "checkRow.")
        ).firstMatch
        XCTAssertTrue(checkButton.waitForExistence(timeout: 3), "Expected a 'Check Row' button to appear")
        checkButton.tap()

        // Verify changes were persisted
        let subtotalButton = app.buttons["Subtotal"]
        XCTAssertTrue(subtotalButton.waitForExistence(timeout: 3), "Expected a 'subtotal' button to appear")
        let priceOwedLabel = app.staticTexts["$21.00"]
        XCTAssertTrue(priceOwedLabel.waitForExistence(timeout: 5), "Expected '$21.00' to be visible on screen after selecting the contact")
    }
}

