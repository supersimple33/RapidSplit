//
//  Helpers.swift
//  RapidSplitUITests
//
//  Created by Addison Hanrattie on 11/24/25.
//

import Foundation
import XCTest

@MainActor
func resetApp() {
    let app = XCUIApplication()
    app.launchArguments.append(LaunchArguments.reset.rawValue)
    app.launch()
    app.tap()
    app.terminate()
}

@MainActor
func seedApp() {
    let app = XCUIApplication()
    app.launchArguments.append(LaunchArguments.seed.rawValue)
    app.launch()
    app.tap()
    app.terminate()
}

@MainActor
func openPhotoInApp(link: String) {
    let safari: XCUIApplication = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
    safari.launch()

    _ = safari.wait(for: .runningForeground, timeout: 30)

    // Handle first-run overlay
    let continueButton = safari.buttons["Continue"]
    if continueButton.waitForExistence(timeout: 10) {
        continueButton.tap()
    }

    let searchBar = safari.descendants(matching: .any).matching(identifier: "Address").firstMatch
    searchBar.tap()
    safari.typeText(link)
    safari.typeText(XCUIKeyboardKey.return.rawValue)

    // Wait for image load
    let image = safari.images.firstMatch
    XCTAssertTrue(image.waitForExistence(timeout: 15), "Image did not load")

    tapButton("More", in: safari)

    tapButton("Share", in: safari)

    let rapidSplitButton = safari.descendants(matching: .any)
        .matching(NSPredicate(format: "label == %@", "RapidSplit"))
        .firstMatch
    if !rapidSplitButton.waitForExistence(timeout: 5) {
        tapButton("Options ", in: safari)
        let imageButton = safari.staticTexts["Image"]
        XCTAssertTrue(imageButton.waitForExistence(timeout: 2), "Image button didn't appear")
        imageButton.tap()
        tapButton("Done", in: safari)
    }
    XCTAssertTrue(rapidSplitButton.waitForExistence(timeout: 3), "RapidSplit app not found in share sheet")
    rapidSplitButton.tap()
}

@MainActor
func findElement(named name: String, in root: XCUIElement) -> XCUIElement {
    let predicate = NSPredicate(format: "label == %@ OR identifier == %@", name, name)
    return root.descendants(matching: .any)
        .matching(predicate)
        .firstMatch
}

@MainActor
func enterText(
    _ text: String,
    into textField: XCUIElement,
    in app: XCUIApplication,
    erasing: Bool = true,
    check: String? = nil
) {
    // Ensure the text field is hittable and focused
    XCTAssertTrue(textField.waitForExistence(timeout: 5), "Text field did not appear")
    textField.tap()

    // Try Select All and replace if there's existing text
    let currentValue = textField.value as? String ?? ""
    if !currentValue.isEmpty && erasing {
        textField.press(forDuration: 0.5)
        let selectAll = app.menuItems["Select All"]
        if selectAll.waitForExistence(timeout: 1) {
            selectAll.tap()
            // Typing new text will replace selection
            textField.typeText(text)
        } else {
            // Fallback: send backspace characters rather than tapping the delete key element
            let deleteSequence = String(repeating: "\u{8}", count: currentValue.count)
            textField.typeText(deleteSequence)
            textField.typeText(text)
        }
    } else {
        // No existing text, just type
        textField.typeText(text)
    }

    // Dismiss keyboard if needed by tapping return when present
    dismissKeyboard(in: app)

    // Assert the text field now contains the typed text (prefer accessibilityValue over value)
    let valueString: String = {
        if let accessibility = textField.accessibilityValue, accessibility.isEmpty == false {
            return accessibility
        }
        let staticText = textField.descendants(matching: .staticText).firstMatch
        if staticText.exists, let label = staticText.label as String?, label.isEmpty == false {
            return label
        }
        return (textField.value as? String) ?? ""
    }()

    if !IS_RUNNING_CI {
        if let check {
            XCTAssertEqual(valueString, check, "Text field should contain the text that was typed: \(valueString) vs \(check)")
        } else {
            XCTAssertEqual(valueString, text, "Text field should contain the text that was typed: \(valueString) vs \(text)")
        }
    }
}

@MainActor
func dismissKeyboard(in app: XCUIApplication) {
    // If no keyboard is present, nothing to do
    guard app.keyboards.firstMatch.exists else { return }

    // Try common submit/return button labels (as buttons or keys)
    let candidates = ["Return", "Done", "Go", "Search", "Next", "Join", "Send"]

    for label in candidates {
        if app.keyboards.buttons[label].exists {
            app.keyboards.buttons[label].tap()
            return
        }
        if app.keyboards.keys[label].exists {
            app.keyboards.keys[label].tap()
            return
        }
    }

    // Some setups expose a lowercase "return" key
    if app.keyboards.keys["return"].exists {
        app.keyboards.keys["return"].tap()
        return
    }

    // As a last resort, type a newline which usually triggers submit/dismiss
    app.typeText("\n")
}

@MainActor
func tapButton(_ name: String, in app: XCUIApplication, timeout: TimeInterval = 3) {
    let button = app.buttons[name]
    XCTAssertTrue(button.waitForExistence(timeout: timeout), "\(name) button didn't appear")
    button.tap()
}
