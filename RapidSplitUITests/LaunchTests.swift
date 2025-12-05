//
//  RapidSplitUITestsLaunchTests.swift
//  RapidSplitUITests
//
//  Created by Addison Hanrattie on 9/6/25.
//

import XCTest

final class LaunchTests: AlertDismissingTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        self.continueAfterFailure = false

        // Skip UI performance tests when running in CI to avoid flaky results and long runtimes
        if !isRunningCI {
            throw XCTSkip("Skipping UI performance tests on CI environment.")
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        resetApp() // Setup

        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testSeededLaunchPerformance() throws {
        seedApp() // Setup

        measure(metrics: [XCTApplicationLaunchMetric(waitUntilResponsive: true)]) {
            XCUIApplication().launch()
        }
    }
}
