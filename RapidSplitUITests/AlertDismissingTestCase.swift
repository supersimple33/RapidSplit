//
//  AlertDismissingTest.swift
//  RapidSplitUITests
//
//  Created by Addison Hanrattie on 12/2/25.
//

import XCTest

class AlertDismissingTestCase: XCTestCase {

    @MainActor private static var didClearPermissions = false

    @MainActor
    override func setUp() async throws {
        try await super.setUp()

        // Clear camera (and other) permission alerts once per test class
        guard !Self.didClearPermissions else { return }

        let app = self.getAppWithEnv()
        let monitor = self.addUIInterruptionMonitor(withDescription: "Handle system alerts") { alert in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            if alert.buttons["Allow While Using App"].exists {
                alert.buttons["Allow While Using App"].tap()
                return true
            }
            if alert.buttons["Don’t Allow"].exists {
                alert.buttons["Don’t Allow"].tap()
                return true
            }
            return false
        }

        // Launch once to surface any alerts, then interact to trigger the interruption monitor
        app.launch()
        app.tap()

        // Clean up and terminate so tests start from a clean state
        self.removeUIInterruptionMonitor(monitor)
        app.terminate()

        Self.didClearPermissions = true
    }

    @MainActor
    final func getAppWithEnv() -> XCUIApplication {
        let app = XCUIApplication()

        if let CI = ProcessInfo.processInfo.environment["CI"] {
            app.launchEnvironment["CI"] = CI
        }

        return app
    }
}
