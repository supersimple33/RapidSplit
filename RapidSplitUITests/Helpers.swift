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

    let searchBar = safari.descendants(matching: .any).matching(identifier: "Address").firstMatch
    searchBar.tap()
    safari.typeText(link)
    safari.typeText(XCUIKeyboardKey.return.rawValue)

    let moreButton = safari.buttons["More"]
    XCTAssertTrue(moreButton.waitForExistence(timeout: 5), "More button didn't appear")
    moreButton.tap()

    let shareButton = safari.buttons["Share"]
    XCTAssertTrue(shareButton.waitForExistence(timeout: 5), "Share button didn't appear")
    shareButton.tap()

    let rapidSplitButton = safari.descendants(matching: .any)
        .matching(NSPredicate(format: "label == %@", "RapidSplit"))
        .firstMatch
    XCTAssertTrue(rapidSplitButton.waitForExistence(timeout: 5), "RapidSplit app not found in share sheet")
    rapidSplitButton.tap()
}

@MainActor
func findElement(named name: String, in root: XCUIElement) -> XCUIElement {
    let predicate = NSPredicate(format: "label == %@ OR identifier == %@", name, name)
    return root.descendants(matching: .any)
        .matching(predicate)
        .firstMatch
}
