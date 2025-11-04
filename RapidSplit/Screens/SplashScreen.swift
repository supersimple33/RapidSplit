//
//  SplashScreen.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/15/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            HomeScreen()
                .environment(router)
                .navigationDestination(for: Router.Route.self) { route in
                    switch route {
                    case .capture:
                        CaptureScreen().environment(router)
                    case .analysis(let image):
                        CheckAnalysisScreen(image: image).environment(router)
                    case .overview(let title, let items):
                        CheckOverviewScreen(title: title, items: items).environment(router)
                    case .participants(let check):
                        IdentifyParticipantsScreen(check: check, showContinue: true).environment(router)
                    case .assignment(let check):
                        ItemAssignmentScreen(check: check, showContinue: true).environment(router)
                    case .details(let check):
                        CheckDetailsScreen(check: check).environment(router)
                    }
                }
        }
    }
}

#Preview {
    SplashScreen()
}
