//
//  RapidSplitUITestsLaunchTests.swift
//  RapidSplitUITests
//
//  Created by Addison Hanrattie on 9/6/25.
//

import XCTest

final class RapidSplitUITestsLaunchTests: XCTestCase {

    @MainActor private static var didClearPermissions = false

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    @MainActor
    override func setUp() async throws {
        self.continueAfterFailure = false

        // Clear camera (and other) permission alerts once per test class
        guard !Self.didClearPermissions else { return }

        let app = XCUIApplication()
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
    func testLaunchPerformance() throws {
        // Setup
        let app = XCUIApplication()
        app.launchArguments.append(LaunchArguments.reset.rawValue)
        app.launch()
        app.tap()
        app.terminate()

        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testSeededLaunchPerformanc() throws {
        // Setup
        let app = XCUIApplication()
        app.launchArguments.append(LaunchArguments.seed.rawValue)
        app.launch()
        app.tap()
        app.terminate()

        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            XCUIApplication().launch()
        }
    }
}
