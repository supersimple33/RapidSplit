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
