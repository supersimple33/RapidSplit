//
//  Router.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/15/25.
//

import Foundation
import SwiftUI

@Observable
class Router {
    var navigationPath = NavigationPath()

    enum Route: Hashable, CustomDebugStringConvertible {
        case capture
        case analysis(image: UIImage)
        case overview(title: String, items: [GeneratedItem])
        case participants(check: Check)
        case assignment(check: Check)
        case details(check: Check)

        var debugDescription: String {
            switch self {
            case .capture: return "Capture"
            case .analysis: return "Analysis"
            case .overview: return "Overview"
            case .participants: return "Participants"
            case .assignment: return "Assignment"
            case .details: return "Details"
            }
        }
    }

    func navigateTo(route: Route) {
        navigationPath.append(route)
    }

    func jumpToCheck(check: Check) {
        self.navigationPath = NavigationPath([Route.details(check: check)])
    }

    func jumpToAnalysis(of image: UIImage) {
        self.navigationPath = NavigationPath([Route.analysis(image: image)])
    }

}
