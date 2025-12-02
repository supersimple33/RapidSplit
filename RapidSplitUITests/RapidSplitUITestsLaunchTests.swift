//
//  RapidSplitUITestsLaunchTests.swift
//  RapidSplitUITests
//
//  Created by Addison Hanrattie on 9/6/25.
//

import XCTest

final class RapidSplitUITestsLaunchTests: AlertDismissingTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        self.continueAfterFailure = false
    }

    @MainActor
    func testLaunchPerformance() throws {
        resetApp() // Setup

        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testSeededLaunchPerformanc() throws {
        seedApp() // Setup

        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            XCUIApplication().launch()
        }
    }
}
